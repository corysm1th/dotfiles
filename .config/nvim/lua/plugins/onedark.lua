return {

    -- add onedark
    {
        "navarasu/onedark.nvim",
        opts = {
            style = "darker",
            colors = {
                bg0 = "#101010",
                bg1 = "#181818",
                grey = "#70787f",
            },
        },
    },

    -- Configure LazyVim to load onedark
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "onedark",
        },
    },
}

