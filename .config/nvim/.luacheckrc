-- luacheck config for the nvim config itself: recognize the globals the
-- nvim runtime and plugins provide so nvim-lint doesn't flag them.
globals = { 'vim' }
read_globals = { 'Snacks' }
max_line_length = false
