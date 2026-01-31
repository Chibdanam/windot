--[[
============================================================================================
    OPTIONS VSCODE NEOVIM EXTENSION
============================================================================================

  Ce fichier contient une configuration MINIMALE pour l'extension VSCode Neovim.

  POURQUOI UNE CONFIGURATION SÉPARÉE ?
  ------------------------------------
  L'extension VSCode Neovim utilise Neovim comme moteur pour les mouvements et l'édition,
  mais l'interface visuelle reste celle de VSCode. Beaucoup d'options de Neovim n'ont donc
  aucun effet dans ce contexte car elles contrôlent des éléments d'interface que VSCode gère.

  OPTIONS QUI NE FONCTIONNENT PAS DANS VSCODE :
    ✗ vim.opt.number / relativenumber   - VSCode gère l'affichage des numéros de ligne
    ✗ vim.opt.scrolloff                 - VSCode contrôle le défilement
    ✗ vim.opt.wrap                      - VSCode gère le word wrap
    ✗ vim.opt.virtualedit               - Géré par l'éditeur VSCode
    ✗ vim.opt.termguicolors             - VSCode utilise son propre système de thème
    ✗ Plugins visuels (colorschemes, statusline, etc.) - Inutiles dans VSCode

  OPTIONS QUI FONCTIONNENT DANS VSCODE :
    ✓ Leader key et keybindings personnalisés
    ✓ Options d'édition (tabstop, expandtab, shiftwidth)
    ✓ Options de recherche (ignorecase, smartcase)
    ✓ Clipboard système
    ✓ Comportement des splits (si utilisés via commandes Neovim)
    ✓ Options de substitution (inccommand)

  NOTE: Cette configuration ne charge PAS les plugins (pas de lazy.nvim en mode VSCode).
        Pour les fonctionnalités avancées, utilisez les extensions VSCode natives.

  RÉFÉRENCE: Pour voir toutes les options disponibles en mode standalone, consultez lua/options.lua
--]]

-- [[ Leader Key ]]
--  Map la leader key avec la touche espace
--  Permet de faire des raccourcis clavier custom sans pour autant défaire les raccourcis existant
--  juste en forçant un prefix avec la leaderkey
--  (à tout moment il y a des side effects à ça, à voir)
--
--  NOTE: Les keybindings définis avec <leader> fonctionnent dans VSCode !
--  Voir :help mapleader
vim.g.mapleader = " "

-- [[ Comportement des Fenêtres Splitées ]]
--  Modifie la position de la fenêtre splitée
--  Si vous utilisez :split ou :vsplit dans VSCode, ces options s'appliquent
--
--  Voir :help 'splitbelow' et :help 'splitright'
vim.opt.splitbelow = true
vim.opt.splitright = true

-- [[ Gestion des Tabulations ]]
--  Convertit les tab en spaces
--  Ces options affectent comment Tab et l'indentation fonctionnent dans VSCode
--
--  NOTE: VSCode a ses propres paramètres pour les tabs ; ces options Neovim les complètent
--  Voir :help 'expandtab', :help 'tabstop', :help 'shiftwidth'
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

-- [[ Clipboard Système ]]
--  Bind le clipboard de nvim à celui de Windows/Linux/Mac
--  Permet de copier/coller entre Neovim et d'autres applications
--
--  NOTE: Fonctionne avec les commandes Neovim comme yy et p
--  Voir :help 'clipboard'
vim.opt.clipboard = "unnamedplus"

-- [[ Prévisualisation des Substitutions ]]
--  Permet d'afficher une preview pour genre les remplacements
--  Affiche un aperçu en temps réel des commandes :%s/ancien/nouveau/
--
--  NOTE: Cette fonctionnalité fonctionne dans VSCode !
--  Voir :help 'inccommand'
vim.opt.inccommand = "split"

-- [[ Recherche ]]
--  Ignore la casse lors de la recherche
--  Rend les recherches Neovim (/, ?, *, #) insensibles à la casse
--
--  TODO: Ajouter vim.opt.smartcase = true pour un comportement intelligent
--  Voir :help 'ignorecase'
vim.opt.ignorecase = true

-- [[ TODO: Options Supplémentaires pour VSCode ]]
--  TODO: Configurer des keybindings personnalisés pour VSCode via vim.keymap.set()
--  TODO: Explorer les commandes VSCode disponibles via :lua vim.fn.VSCodeNotify()
--  TODO: Ajouter vim.opt.smartcase = true pour respecter la casse avec majuscules


