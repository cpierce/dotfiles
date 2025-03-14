return {
  view_options = {
    show_hidden = true,
    is_hidden_file = function(name, _)
      return name ~= '.git' and name ~= 'node_modules'
    end,
  },
}
