# Build a nested markdown list from dot-separated ids, with clickable CSV links.
# Each group level becomes a bold bullet; leaf nodes become linked bullets.
build_hierarchy <- function(ids, depth = 1L) {
  segs <- strsplit(ids, "\\.", fixed = FALSE)
  seg_at_depth <- vapply(segs, function(s) if (length(s) >= depth) s[[depth]] else "", "")
  indent <- strrep("  ", depth - 1L)
  lines <- character(0)
  for (g in sort(unique(seg_at_depth))) {
    idx <- which(seg_at_depth == g)
    child_ids <- ids[idx]
    child_lens <- vapply(segs[idx], length, 0L)
    leaves    <- child_ids[child_lens == depth]
    nonleaves <- child_ids[child_lens >  depth]
    if (length(nonleaves) == 0L) {
      for (id in leaves)
        lines <- c(lines, sprintf("%s- [%s](csv/%s.csv)", indent, id, id))
    } else {
      lines <- c(lines, sprintf("%s- **%s**", indent, g))
      lines <- c(lines, build_hierarchy(nonleaves, depth + 1L))
      for (id in leaves)
        lines <- c(lines, sprintf("%s  - [%s](csv/%s.csv)", indent, id, id))
    }
  }
  lines
}

# Replace the content of one ## section in index.md with new_lines.
# Everything between the section header and the next ## header is overwritten.
update_index_section <- function(index_path, section, new_lines) {
  txt <- readLines(index_path, warn = FALSE)
  h_idx <- grep(paste0("^## ", section), txt)[[1L]]
  next_h <- grep("^## ", txt)
  next_h <- next_h[next_h > h_idx]
  end_idx <- if (length(next_h) > 0L) next_h[[1L]] - 1L else length(txt)
  writeLines(
    c(txt[seq_len(h_idx)], "", new_lines,
      if (end_idx < length(txt)) c("", txt[(end_idx + 1L):length(txt)]) else character(0)),
    index_path
  )
}
