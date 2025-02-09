return {

    -- add onedark
    {
        "navarasu/onedark.nvim",
        opts = { style = "darker" },
    },

    -- Configure LazyVim to load onedark
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "onedark",
        },
    },
}

