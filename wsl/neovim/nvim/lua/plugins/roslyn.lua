--[[
============================================================================================
    ROSLYN.NVIM - SERVEUR LSP C# MODERNE
============================================================================================

  QU'EST-CE QUE ROSLYN ?
  ----------------------
  Roslyn est le compilateur C# officiel de Microsoft et son serveur LSP. C'est le même
  serveur utilisé par Visual Studio Code pour le support C#. Il remplace OmniSharp qui
  n'est plus maintenu activement.

  POURQUOI ROSLYN PLUTÔT QU'OMNISHARP ?
    • Activement maintenu par Microsoft
    • Même serveur que VSCode (garantit la compatibilité)
    • Support des dernières fonctionnalités C# (.NET 8+)
    • Support des fichiers générés par le compilateur (source generators)
    • Gestion intelligente de multiples solutions (.sln)
    • Actions de code avancées (Fix All, nested code actions)

  PRÉREQUIS :
    • Neovim >= 0.11.0
    • .NET SDK installé avec la commande `dotnet` disponible
    • Roslyn installé via Mason (voir instructions ci-dessous)

  INSTALLATION DU SERVEUR ROSLYN :
    1. Redémarrez Neovim après avoir ajouté ce fichier
    2. Le registre Mason personnalisé sera configuré automatiquement
    3. Exécutez :MasonInstall roslyn
       OU :MasonInstall roslyn-unstable (pour les fonctionnalités de pointe)
    4. Le serveur sera téléchargé et configuré automatiquement

  FONCTIONNALITÉS PRINCIPALES :
    • Autocomplétion intelligente C#
    • Navigation dans le code (aller à la définition, références)
    • Diagnostics en temps réel (erreurs, warnings)
    • Actions de code (refactoring, quick fixes)
    • Support des inlay hints (types implicites, paramètres)
    • Code lens (références, tests)
    • Support multi-solutions (switch entre différents .sln)

  COMMANDES ROSLYN :
    :Roslyn start    - Démarre le serveur Roslyn
    :Roslyn stop     - Arrête le serveur Roslyn
    :Roslyn restart  - Redémarre le serveur Roslyn
    :Roslyn target   - Change de solution .sln (si plusieurs dans le projet)

  NOTE: Roslyn ne supporte PAS les fichiers Razor (.razor, .cshtml).
        Pour Razor, utilisez le plugin rzls.nvim en complément.

  Voir :help roslyn.nvim pour plus d'informations
--]]

return {
    "seblj/roslyn.nvim",
    -- NOTE: Roslyn utilise le système de filetype pour se déclencher sur les fichiers .cs
    ft = "cs",

    config = function()
        -- [[ Configuration de Roslyn ]]
        --  Configuration par défaut avec des options sensibles.
        --  Personnalisez selon vos besoins en décommentant les options ci-dessous.

        require("roslyn").setup({
            -- [[ Options de Base ]]

            -- Gestion du file watching (surveillance des changements de fichiers)
            -- "auto" : laisse Roslyn décider (recommandé)
            -- true   : Roslyn surveille les changements
            -- false  : Désactive la surveillance (économise des ressources)
            filewatching = "auto",

            -- Recherche élargie : cherche les .sln dans les dossiers parents
            -- Si false, utilise seulement le dossier de travail actuel
            -- TIP: Activez si vos .sln sont dans des dossiers parents
            broad_search = false,

            -- Verrouille la solution sélectionnée après le premier attachement
            -- Utile si vous avez plusieurs .sln et voulez rester sur une seule
            lock_target = false,

            -- Mode silencieux : désactive les notifications d'initialisation
            -- Si true, Roslyn démarre sans afficher de messages
            silent = false,

            -- [[ Configuration Avancée ]]
            -- Configuration LSP avec handlers pour rzls (support Razor/Blazor)
            --
            -- NOTE: rzls.nvim nécessite que Roslyn utilise ses handlers spéciaux
            --       pour communiquer avec le serveur Razor Language Server.
            --       Si vous n'utilisez pas Razor/Blazor, vous pouvez commenter cette section.
            config = {
                -- Handlers personnalisés pour l'intégration avec rzls
                -- Ces handlers permettent à Roslyn de traiter les requêtes spécifiques à Razor
                handlers = require("rzls.roslyn_handlers"),

                -- Décommentez pour ajouter d'autres configurations :
                -- capabilities = require('cmp_nvim_lsp').default_capabilities(),
            },

            -- [[ Inlay Hints - Indices Visuels ]]
            --  Les inlay hints affichent des informations supplémentaires dans l'éditeur
            --  comme les types de variables implicites ou les noms de paramètres.
            --
            --  Décommentez pour activer :
            --
            -- on_attach = function(client, bufnr)
            --     -- Active les inlay hints pour ce buffer
            --     if client.server_capabilities.inlayHintProvider then
            --         vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
            --     end
            -- end,
        })

        -- [[ Configuration des Inlay Hints via vim.lsp.config ]]
        --  Alternative pour configurer les inlay hints globalement pour Roslyn.
        --  Décommentez pour personnaliser :
        --
        -- vim.lsp.config("roslyn", {
        --     settings = {
        --         ["csharp|inlay_hints"] = {
        --             csharp_enable_inlay_hints_for_implicit_variable_types = true,
        --             csharp_enable_inlay_hints_for_lambda_parameter_types = true,
        --             csharp_enable_inlay_hints_for_types = true,
        --             dotnet_enable_inlay_hints_for_parameters = true,
        --             dotnet_enable_inlay_hints_for_literal_parameters = true,
        --             dotnet_enable_inlay_hints_for_object_creation_parameters = true,
        --             dotnet_enable_inlay_hints_for_indexer_parameters = true,
        --             dotnet_enable_inlay_hints_for_other_parameters = true,
        --             dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
        --             dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
        --             dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
        --         },
        --         ["csharp|code_lens"] = {
        --             dotnet_enable_references_code_lens = true,
        --             dotnet_enable_tests_code_lens = true,
        --         },
        --     },
        -- })
    end,
}

-- [[ TODO: Améliorations Roslyn ]]
--
--  PLUGINS COMPLÉMENTAIRES POUR C# :
--    • rzls.nvim              - Support des fichiers Razor (.cshtml, .razor)
--    • nvim-dap               - Débogueur pour C# avec netcoredbg ou vsdbg
--    • neotest-dotnet         - Exécution de tests C# dans Neovim
--
--  CONFIGURATION AVANCÉE :
--    • Personnaliser les inlay hints selon vos préférences
--    • Configurer les code lens pour afficher les références et tests
--    • Ajouter des snippets C# personnalisés
--    • Configurer le formateur (stylecop, csharpier, etc.)
--
--  GESTION MULTI-SOLUTIONS :
--    Si votre projet contient plusieurs fichiers .sln :
--      1. Ouvrez un fichier .cs
--      2. Exécutez :Roslyn target
--      3. Sélectionnez la solution à utiliser
--      4. Roslyn se reconnectera avec la bonne solution
--
--  DÉPANNAGE :
--    • Si Roslyn ne démarre pas : Vérifiez que dotnet est installé avec `dotnet --version`
--    • Si les diagnostics ne s'affichent pas : Exécutez :LspInfo pour voir l'état
--    • Si l'autocomplétion ne fonctionne pas : Vérifiez que vous avez un plugin de complétion (nvim-cmp)
--    • Consultez les logs : :Roslyn restart et vérifiez :messages
--
--  COMMANDES UTILES :
--    :LspInfo                 - Affiche l'état de tous les serveurs LSP
--    :LspRestart              - Redémarre tous les serveurs LSP
--    :Mason                   - Ouvre l'interface Mason pour gérer Roslyn
--
--  NOTE: Pour vérifier que Roslyn est bien installé :
--    1. Exécutez :Mason
--    2. Cherchez "roslyn" dans la liste
--    3. Il devrait être marqué comme installé
--
--  Voir https://github.com/seblj/roslyn.nvim pour la documentation complète
