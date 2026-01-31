--[[
============================================================================================
    TREESITTER - ANALYSE SYNTAXIQUE ET COLORATION AVANCÉE
============================================================================================

  QU'EST-CE QUE TREESITTER ?
  ---------------------------
  Treesitter est un parseur (analyseur syntaxique) qui comprend la STRUCTURE du code,
  pas seulement les mots-clés. Il construit un arbre syntaxique abstrait (AST) du code
  en temps réel, ce qui permet :

    • Coloration syntaxique précise et contextuelle (mieux que regex)
    • Sélection incrémentale intelligente (sélectionner des blocs de code logiques)
    • Indentation automatique basée sur la structure du code
    • Navigation dans le code par nœuds syntaxiques
    • Pliage de code (folding) intelligent
    • Et bien plus...

  DIFFÉRENCE AVEC LA COLORATION CLASSIQUE :
    Regex-based syntax (ancien) : Colore "function" partout pareil
    Treesitter (moderne)        : Distingue la déclaration de fonction, l'appel, le mot-clé

  EXEMPLE :
    function hello()  -- "function" et "hello" colorés différemment
        hello()       -- "hello" ici est coloré comme un appel de fonction
    end

  NOTE: Treesitter télécharge automatiquement les parseurs pour chaque langage.
        Les parseurs sont des fichiers .so compilés.

  Voir :help nvim-treesitter pour la documentation complète
--]]

return {
    "nvim-treesitter/nvim-treesitter",
    config = function()
        require("nvim-treesitter.configs").setup({
            -- [[ Installation des Parseurs ]]
            --  Liste des parseurs à installer automatiquement au premier lancement.
            --
            --  PARSEURS ACTUELLEMENT INSTALLÉS :
            --    • c       - Langage C (utile pour comprendre le code C dans Neovim)
            --    • lua     - Lua (pour configurer Neovim)
            --    • vim     - Vimscript (ancien langage de config Vim)
            --    • vimdoc  - Documentation Vim/Neovim (pour :help)
            --    • query   - Langage de requête Treesitter (pour customiser les queries)
            --
            --  TODO: Ajoutez les langages que vous utilisez :
            --    "python", "javascript", "typescript", "rust", "go", "html", "css", "json", etc.
            --
            --  NOTE: Vous pouvez voir tous les parseurs disponibles avec :TSInstallInfo
            ensure_installed = { "c", "lua", "vim", "vimdoc", "query" },

            -- Installation automatique des parseurs manquants
            -- Quand vous ouvrez un fichier dans un nouveau langage, le parseur sera installé automatiquement
            --
            -- WARN: Nécessite git ou curl installé sur le système
            auto_install = true,

            -- [[ Module : Coloration Syntaxique (Highlight) ]]
            --  Active la coloration syntaxique basée sur Treesitter.
            --  Remplace l'ancien système de coloration basé sur regex.
            --
            --  AVANTAGES :
            --    • Plus précis et contextuel
            --    • Supporte les injections de langage (ex: SQL dans Python, JS dans HTML)
            --    • Performances optimales même sur de gros fichiers
            --
            --  NOTE: Si la coloration semble cassée, exécutez :TSUpdate pour mettre à jour les parseurs
            --  Voir :help treesitter-highlight
            highlight = {
                enable = true,
            },

            -- [[ Module : Sélection Incrémentale ]]
            --  Permet de sélectionner intelligemment du code en se basant sur l'arbre syntaxique.
            --  Au lieu de sélectionner caractère par caractère, vous sélectionnez des "nœuds" logiques.
            --
            --  WORKFLOW TYPIQUE :
            --    1. Placez le curseur dans une fonction
            --    2. Appuyez sur <leader>ss (start selection) : sélectionne le mot sous le curseur
            --    3. Appuyez sur <leader>si (increment) : sélectionne la ligne, puis le bloc, puis la fonction
            --    4. Appuyez sur <leader>sd (decrement) : revient à la sélection précédente
            --
            --  EXEMPLE CONCRET :
            --    Curseur sur "x" :  x = 10
            --    <leader>ss     →  [x] est sélectionné (identifiant)
            --    <leader>si     →  [x = 10] est sélectionné (assignation)
            --    <leader>si     →  toute la ligne est sélectionnée
            --    <leader>si     →  tout le bloc/fonction est sélectionné
            --
            --  TIP: Extrêmement utile pour refactorer ou copier des blocs de code complets
            --  Voir :help nvim-treesitter-incremental-selection-mod
            incremental_selection = {
                enable = true,
                keymaps = {
                    -- Démarre la sélection (Select Start)
                    init_selection = "<leader>ss",
                    -- Augmente la sélection au nœud parent (Select Increment)
                    node_incremental = "<leader>si",
                    -- Augmente au niveau du scope (fonction, classe, etc.) (Select sCope)
                    scope_incremental = "<leader>sc",
                    -- Diminue la sélection au nœud enfant (Select Decrement)
                    node_decremental = "<leader>sd",
                },
            },
        })
    end,
}

-- [[ TODO: Modules Treesitter Supplémentaires ]]
--
--  Treesitter offre bien plus que la coloration et la sélection !
--  Voici des modules supplémentaires à explorer :
--
--  MODULES INTÉGRÉS (activables dans setup()) :
--    • indent : Indentation automatique intelligente basée sur l'AST
--        indent = { enable = true }
--
--    • fold : Pliage de code basé sur la structure syntaxique
--        Nécessite : vim.opt.foldmethod = 'expr' et vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
--
--  PLUGINS ADDITIONNELS POPULAIRES :
--    • nvim-treesitter-textobjects : Objets textuels (sélectionner fonctions, classes, etc. avec des commandes)
--        Exemple : "vif" sélectionne l'intérieur d'une fonction
--
--    • nvim-treesitter-context : Affiche le contexte (fonction/classe courante) en haut de l'écran
--
--    • nvim-ts-rainbow : Colore les parenthèses/brackets par paires avec des couleurs différentes
--
--    • nvim-ts-autotag : Ferme automatiquement les balises HTML/XML
--
--  COMMANDES UTILES :
--    :TSInstall <langage>    - Installe un parseur manuellement
--    :TSInstallInfo          - Liste tous les parseurs disponibles
--    :TSUpdate              - Met à jour tous les parseurs installés
--    :TSUninstall <langage> - Désinstalle un parseur
--    :InspectTree           - Affiche l'arbre syntaxique du fichier (utile pour déboguer)
--
--  Voir :help nvim-treesitter-modules pour tous les modules disponibles
