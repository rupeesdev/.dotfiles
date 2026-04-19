return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    opts.sections = opts.sections or {}

    opts.sections.lualine_a = {
      {
        "mode",
        icon = "", -- Manzana para macOS
      },
    }

    opts.sections.lualine_b = {
      "branch",
      "diff",
    }

    opts.sections.lualine_c = {
      {
        "filename",
        path = 1, -- 0 = solo nombre, 1 = relativo, 2 = absoluto
      },
      "diagnostics",
    }

    opts.sections.lualine_x = {
      "encoding",
      {
        "fileformat",
        symbols = {
          unix = "󰘳",
          dos = "DOS",
          mac = "MAC",
        },
      },
      {
        "filetype",
        colored = true,
        icon_only = false,
      },
    }
    opts.sections.lualine_y = { "progress" }

    opts.sections.lualine_z = {
      "location",
      {
        function()
          return "☰ " .. vim.fn.line("$")
        end,
      },
    }

    return opts
  end,
}
