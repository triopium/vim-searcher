# vim-searcher
* search pattern and list occurences in split buffer. Pressing <CR> goes to that occurence
* fulltext search in specified directory, buffer, buffers

# Dependency
* triorg/vim-array
* triorg/vim-buffer

# Commands
* Grep current buffer
SearcherGrepBuffer <pattern>
* Grep buffers
SearcherGrepBuffers <pattern>
* Grep dir
SearcherGrepDir <pattern> <directory>

# Example mapping
nnoremap <leader>j :SearcherGrep
