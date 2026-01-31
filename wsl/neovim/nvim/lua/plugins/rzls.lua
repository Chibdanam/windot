--[[
============================================================================================
    RZLS.NVIM - SERVEUR LSP RAZOR/BLAZOR
============================================================================================

  QU'EST-CE QUE RZLS ?
  --------------------
  rzls (Razor Language Server) est le serveur LSP officiel de Microsoft pour les fichiers
  Razor/Blazor/CSHTML utilisés dans le développement web ASP.NET Core.

  Razor est un moteur de template qui mélange C# et HTML pour créer des pages web dynamiques.
  Blazor est un framework pour créer des applications web interactives avec C# au lieu de JavaScript.

  TYPES DE FICHIERS SUPPORTÉS :
    • .razor  - Composants Blazor
    • .cshtml - Pages Razor (ASP.NET MVC/Pages)

  FONCTIONNALITÉS :
    • Autocomplétion pour C# et HTML dans les fichiers Razor
    • Diagnostics en temps réel (erreurs de syntaxe, types manquants, etc.)
    • Navigation (aller à la définition, références)
    • Formatage du code
    • Support des directives Razor (@page, @code, @inject, etc.)

  PRÉREQUIS :
    • roslyn.nvim installé et configuré (voir lua/plugins/roslyn.lua)
    • html-lsp installé via Mason (pour le support HTML)
    • rzls installé via Mason avec le registre Crashdummyy (déjà configuré)

  INSTALLATION :
    1. Assurez-vous que roslyn.nvim est installé et fonctionne
    2. Exécutez :MasonInstall html-lsp
    3. Exécutez :MasonInstall rzls
    4. Redémarrez Neovim
    5. Ouvrez un fichier .razor ou .cshtml

  IMPORTANT :
    • Ce plugin NE FONCTIONNE PAS sous Windows natif (problème de normalisation de chemins)
    • Si vous utilisez Windows, utilisez WSL (Windows Subsystem for Linux)
    • Ouvrez TOUJOURS les fichiers Razor AVANT les fichiers C# (limitation connue)

  ARCHITECTURE :
    rzls.nvim <--> roslyn.nvim <--> Roslyn Language Server
                                          ↓
                                    rzls extension

  Voir :help rzls.nvim pour plus d'informations
--]]

return {
    "tris203/rzls.nvim",

    -- [[ Dépendances Requises ]]
    --  rzls.nvim nécessite roslyn.nvim pour fonctionner.
    --  La dépendance garantit que roslyn.nvim est chargé AVANT rzls.nvim
    dependencies = { "seblyng/roslyn.nvim" },

    -- [[ Trigger sur les Fichiers Razor ]]
    --  Le plugin se charge automatiquement quand vous ouvrez un fichier .razor ou .cshtml
    ft = { "razor" },

    config = function()
        -- [[ Enregistrement des Types de Fichiers Razor ]]
        --  IMPORTANT : Ceci doit être fait AVANT que le plugin ne se charge
        --  pour que Neovim reconnaisse correctement les fichiers Razor
        --
        --  NOTE : Ceci est déjà exécuté automatiquement par le plugin, mais si vous
        --         rencontrez des problèmes de détection, décommentez ces lignes :
        --
        -- vim.filetype.add({
        --     extension = {
        --         razor = "razor",
        --         cshtml = "razor",
        --     },
        -- })

        -- [[ Configuration de rzls ]]
        --  Configuration minimale avec les options par défaut
        require("rzls").setup({
            -- Capabilities LSP (capacités du client Neovim)
            -- nil = utilise les capacités par défaut
            capabilities = nil,

            -- Chemin vers l'exécutable rzls
            -- nil = utilise le chemin par défaut de Mason ($MASON/packages/rzls)
            -- NOTE : Si vous avez compilé rzls manuellement, spécifiez le chemin ici
            path = nil,

            -- Fonction appelée quand le serveur LSP s'attache à un buffer
            -- Utile pour définir des keybindings ou des options spécifiques aux fichiers Razor
            on_attach = function(client, bufnr)
                -- NOTE : Les keybindings LSP généraux (K, gd, gr, etc.) sont déjà définis
                --        dans lua/plugins/lsp-config.lua et fonctionnent automatiquement ici

                -- TODO : Ajoutez des keybindings spécifiques à Razor si nécessaire
                -- Exemple :
                -- vim.keymap.set('n', '<leader>rf', vim.lsp.buf.format, {
                --     buffer = bufnr,
                --     desc = "Formater le fichier Razor"
                -- })
            end,
        })
    end,
}

-- [[ INTÉGRATION AVEC ROSLYN.NVIM ]]
--
--  IMPORTANT : Pour que rzls fonctionne correctement, vous devez configurer roslyn.nvim
--  avec les handlers rzls. Ceci est fait dans lua/plugins/roslyn.lua
--
--  Si vous rencontrez des problèmes, vérifiez que roslyn.lua contient :
--
--  require("roslyn").setup({
--      config = {
--          handlers = require("rzls.roslyn_handlers"),  -- Handlers rzls
--      },
--  })
--
--  Ces handlers permettent à roslyn.nvim de communiquer avec le serveur rzls
--  pour fournir les fonctionnalités Razor.

-- [[ DÉPANNAGE ]]
--
--  ERREUR : "rzls not found" ou "command not found"
--  SOLUTION :
--    1. Vérifiez que rzls est installé : :Mason
--    2. Si absent, installez-le : :MasonInstall rzls
--    3. Redémarrez Neovim
--
--  ERREUR : Pas d'autocomplétion HTML dans les fichiers Razor
--  SOLUTION :
--    1. Installez html-lsp : :MasonInstall html-lsp
--    2. Vérifiez qu'il est activé : :LspInfo (dans un fichier .razor)
--
--  ERREUR : Le LSP ne démarre pas quand j'ouvre un fichier .razor
--  SOLUTION :
--    1. Vérifiez le type de fichier : :set filetype?
--       (devrait afficher "filetype=razor")
--    2. Si ce n'est pas "razor", le plugin ne se charge pas
--    3. Ajoutez manuellement le type de fichier (décommentez les lignes ~31-36)
--
--  ERREUR : "Cannot connect to Roslyn" ou "Roslyn handlers not found"
--  SOLUTION :
--    1. Vérifiez que roslyn.nvim est installé : :Lazy
--    2. Vérifiez que roslyn.lua contient les handlers rzls (voir section ci-dessus)
--    3. Ouvrez d'abord un fichier .razor, PUIS un fichier .cs (ordre important)
--
--  WARN : Sous Windows natif, rzls ne fonctionne pas correctement
--  SOLUTION :
--    Utilisez WSL (Windows Subsystem for Linux) pour le développement Blazor/Razor
--
--  ASTUCE : Fichiers virtuels
--  Les fichiers Razor génèrent des fichiers C# virtuels (nommés __virtual.cs)
--  Ces fichiers apparaissent dans Telescope et peuvent être gênants.
--  Pour les masquer dans Telescope, ajoutez dans lua/plugins/telescope.lua :
--
--  require("telescope").setup({
--      defaults = {
--          file_ignore_patterns = { "%__virtual.cs$" },
--      },
--  })

-- [[ TODO : Améliorations rzls ]]
--
--  CONFIGURATION AVANCÉE :
--    • Configurer des snippets Razor personnalisés
--    • Ajouter des keybindings spécifiques pour les directives Razor
--    • Configurer le formateur pour respecter vos conventions de code
--
--  PLUGINS COMPLÉMENTAIRES :
--    • neotest-dotnet : Exécuter les tests Blazor dans Neovim
--    • nvim-dap + netcoredbg : Déboguer des applications Blazor
--
--  RESSOURCES :
--    • Documentation officielle Razor : https://learn.microsoft.com/aspnet/core/mvc/views/razor
--    • Documentation Blazor : https://learn.microsoft.com/aspnet/core/blazor/
--    • Issues rzls.nvim : https://github.com/tris203/rzls.nvim/issues
--
--  NOTE : Le plugin est encore en développement actif. Certaines fonctionnalités
--         peuvent ne pas fonctionner parfaitement. Consultez régulièrement les
--         mises à jour avec :Lazy update
