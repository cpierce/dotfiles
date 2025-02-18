return {
  is_insert_mode = true,
  replace_engine = {
    sed = {
      cmd = 'sed',
      args = {}, -- this disable the backup -E default
    },
  },
}
