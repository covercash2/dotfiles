# Shell integrations managed by home-manager.
# Nushell config files are linked from the repo via xdg.configFile.
# Chezmoi templates have been converted: platform conditionals use pkgs.stdenv.isDarwin/isLinux.
{ pkgs, ... }:

{
  # direnv — loads .envrc for dev environments
  programs.direnv = {
    enable = true;
    # nushell integration is handled by nushell hooks in config.nu
  };

  # zoxide — cd replacement with memory (generates zoxide.nu for nushell)
  programs.zoxide = {
    enable = true;
    # nushell integration generates the init script automatically
  };

  # carapace — cross-shell completion
  programs.carapace = {
    enable = true;
    # enableNushellIntegration handled below via nushell config
  };

  # Nushell — primary shell
  # Config files live in the repo under dot_config/nushell/ and are managed
  # here via xdg.configFile so chezmoi templating is no longer needed.
  programs.nushell = {
    enable = true;

    # env.nu: environment setup (PATH, ENV_CONVERSIONS, etc.)
    # This is the content from .chezmoitemplates/env.nu with no platform conditionals.
    envFile.text = ''
      $env.STARSHIP_SHELL = "nu"

      $env.ENV_CONVERSIONS = {
        "PATH": {
          from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
          to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
        }
        "Path": {
          from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
          to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
        }
      }

      $env.NU_LIB_DIRS = [
          ($nu.default-config-dir | path join 'scripts')
          ($env.HOME | path join ".config/nushell/scripts")
      ]

      $env.NU_PLUGIN_DIRS = [
          ($nu.default-config-dir | path join 'plugins')
          ($env.HOME | path join '.config/nushell/plugins')
      ]

      $env.user_paths = ([
        "bin",
        ".cargo/bin",
        ".local/bin",
        ".asdf/bin",
        "go/bin"
      ] | each {|path| $nu.home-dir | path join $path })

      $env.PATH = ($env.PATH | prepend ($env.user_paths | where $it not-in $env.PATH))

      if (which zoxide | is-empty) {
        print "zoxide not found"
      } else {
        zoxide init nushell | save --force ~/.zoxide.nu
      }

      if (which nvim | is-empty) {
        print "nvim not found"
      } else {
        $env.EDITOR = (which nvim | get path.0)
      }

      # filter null keys
      def "compact keys" [
        --empty(-e) # filter empty keys as well as null
      ]: record -> record {

        let fn = if $empty {
          {|rc| $rc.value | is-not-empty }
        } else {
          {|rc| $rc.value != null }
        }

        $in
        | transpose key value
        | where $fn
        | transpose -rd
      }
    '';

    # config.nu: main nushell configuration
    # Converted from .chezmoitemplates/config.nu; no chezmoi templating needed.
    configFile.text = ''
      # Nushell Config File

      let dark_theme = {
          separator: white
          leading_trailing_space_bg: { attr: n }
          header: green_bold
          empty: blue
          bool: {|| if $in { 'light_cyan' } else { 'light_gray' } }
          int: white
          filesize: {|e|
            if $e == 0b {
              'white'
            } else if $e < 1mb {
              'cyan'
            } else { 'blue' }
          }
          duration: white
          date: {|| (date now) - $in |
            if $in < 1hr {
              'purple'
            } else if $in < 6hr {
              'red'
            } else if $in < 1day {
              'yellow'
            } else if $in < 3day {
              'green'
            } else if $in < 1wk {
              'light_green'
            } else if $in < 6wk {
              'cyan'
            } else if $in < 52wk {
              'blue'
            } else { 'dark_gray' }
          }
          range: white
          float: white
          string: white
          nothing: white
          binary: white
          cellpath: white
          row_index: green_bold
          record: white
          list: white
          block: white
          hints: dark_gray
          search_result: {bg: red fg: white}
          shape_and: purple_bold
          shape_binary: purple_bold
          shape_block: blue_bold
          shape_bool: light_cyan
          shape_closure: green_bold
          shape_custom: green
          shape_datetime: cyan_bold
          shape_directory: cyan
          shape_external: cyan
          shape_externalarg: green_bold
          shape_filepath: cyan
          shape_flag: blue_bold
          shape_float: purple_bold
          shape_garbage: { fg: white bg: red attr: b}
          shape_globpattern: cyan_bold
          shape_int: purple_bold
          shape_internalcall: cyan_bold
          shape_list: cyan_bold
          shape_literal: blue
          shape_match_pattern: green
          shape_matching_brackets: { attr: u }
          shape_nothing: light_cyan
          shape_operator: yellow
          shape_or: purple_bold
          shape_pipe: purple_bold
          shape_range: yellow_bold
          shape_record: cyan_bold
          shape_redirection: purple_bold
          shape_signature: green_bold
          shape_string: green
          shape_string_interpolation: cyan_bold
          shape_table: blue_bold
          shape_variable: purple
          shape_vardecl: purple
      }

      $env.config = {
        show_banner: false
        ls: {
          use_ls_colors: true
          clickable_links: true
        }
        rm: {
          always_trash: false
        }
        table: {
          mode: compact
          index_mode: always
          show_empty: true
          trim: {
            methodology: wrapping
            wrapping_try_keep_words: true
            truncating_suffix: "..."
          }
        }
        history: {
          max_size: 10000
          sync_on_enter: true
          file_format: "sqlite"
        }
        completions: {
          case_sensitive: false
          quick: true
          partial: true
          algorithm: "prefix"
          external: {
            enable: true
            max_results: 100
            completer: null
          }
        }
        cursor_shape: {
          emacs: line
          vi_insert: line
          vi_normal: blink_block
        }
        color_config: $dark_theme
        footer_mode: 25
        float_precision: 2
        use_ansi_coloring: true
        bracketed_paste: true
        edit_mode: vi
        shell_integration: {
          osc2: true
          osc7: true
          osc8: true
          osc9_9: false
          osc133: true
          osc633: true
          reset_application_mode: true
        }
        render_right_prompt_on_last_line: true
        hooks: {
          pre_prompt: [{||
            if (which direnv | is-empty) {
              return
            }
            direnv export json | from json | default {} | load-env
          }]
          pre_execution: [{||
            null
          }]
          env_change: {
            PWD: [{|before, after|
              null
            }]
          }
          display_output: {||
            if (term size).columns >= 100 { table -e } else { table }
          }
          command_not_found: {||
            null
          }
        }
        menus: [
          {
            name: completion_menu
            only_buffer_difference: false
            marker: "| "
            type: { layout: columnar columns: 4 col_width: 20 col_padding: 2 }
            style: { text: green selected_text: green_reverse description_text: white }
          }
          {
            name: history_menu
            only_buffer_difference: true
            marker: "? "
            type: { layout: list page_size: 10 }
            style: { text: green selected_text: green_reverse description_text: yellow }
          }
          {
            name: help_menu
            only_buffer_difference: true
            marker: "? "
            type: { layout: description columns: 4 col_width: 20 col_padding: 2 selection_rows: 4 description_rows: 10 }
            style: { text: green selected_text: green_reverse description_text: yellow }
          }
          {
            name: commands_menu
            only_buffer_difference: false
            marker: "# "
            type: { layout: columnar columns: 4 col_width: 20 col_padding: 2 }
            style: { text: green selected_text: green_reverse description_text: yellow }
            source: { |buffer, position|
              $nu.scope.commands | where name =~ $buffer | each { |it| {value: $it.name description: $it.usage} }
            }
          }
          {
            name: vars_menu
            only_buffer_difference: true
            marker: "# "
            type: { layout: list page_size: 10 }
            style: { text: green selected_text: green_reverse description_text: yellow }
            source: { |buffer, position|
              $nu.scope.vars | where name =~ $buffer | sort-by name | each { |it| {value: $it.name description: $it.type} }
            }
          }
          {
            name: commands_with_description
            only_buffer_difference: true
            marker: "# "
            type: { layout: description columns: 4 col_width: 20 col_padding: 2 selection_rows: 4 description_rows: 10 }
            style: { text: green selected_text: green_reverse description_text: yellow }
            source: { |buffer, position|
              $nu.scope.commands | where name =~ $buffer | each { |it| {value: $it.name description: $it.usage} }
            }
          }
        ]
        keybindings: [
          {
            name: completion_menu
            modifier: none
            keycode: tab
            mode: [emacs vi_normal vi_insert]
            event: { until: [{ send: menu name: completion_menu } { send: menunext }] }
          }
          {
            name: completion_previous
            modifier: shift
            keycode: backtab
            mode: [emacs, vi_normal, vi_insert]
            event: { send: menuprevious }
          }
          {
            name: history_menu
            modifier: control
            keycode: char_r
            mode: emacs
            event: { send: menu name: history_menu }
          }
          {
            name: next_page
            modifier: control
            keycode: char_x
            mode: emacs
            event: { send: menupagenext }
          }
          {
            name: undo_or_previous_page
            modifier: control
            keycode: char_z
            mode: emacs
            event: { until: [{ send: menupageprevious } { edit: undo }] }
          }
          {
            name: yank
            modifier: control
            keycode: char_y
            mode: emacs
            event: { until: [{edit: pastecutbufferafter}] }
          }
          {
            name: unix-line-discard
            modifier: control
            keycode: char_u
            mode: [emacs, vi_normal, vi_insert]
            event: { until: [{edit: cutfromlinestart}] }
          }
          {
            name: kill-line
            modifier: control
            keycode: char_k
            mode: [emacs, vi_normal, vi_insert]
            event: { until: [{edit: cuttolineend}] }
          }
          {
            name: commands_menu
            modifier: control
            keycode: char_t
            mode: [emacs, vi_normal, vi_insert]
            event: { send: menu name: commands_menu }
          }
          {
            name: vars_menu
            modifier: alt
            keycode: char_o
            mode: [emacs, vi_normal, vi_insert]
            event: { send: menu name: vars_menu }
          }
          {
            name: commands_with_description
            modifier: control
            keycode: char_s
            mode: [emacs, vi_normal, vi_insert]
            event: { send: menu name: commands_with_description }
          }
        ]
      }

      ## integrations

      # starship
      def create_left_prompt [] {
          starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)'
      }

      $env.PROMPT_COMMAND = { || create_left_prompt }
      $env.PROMPT_COMMAND_RIGHT = ""
      $env.PROMPT_INDICATOR = ""
      $env.PROMPT_INDICATOR_VI_INSERT = "▸▶ "
      $env.PROMPT_INDICATOR_VI_NORMAL = "▪◆ "
      $env.PROMPT_MULTILINE_INDICATOR = "::⎬ "

      # carapace completions
      let carapace_completer = {|spans|
          carapace $spans.0 nushell ...$spans | from json
      }

      $env.config.completions.external = {
          enable: true
          max_results: 100
          completer: $carapace_completer
      }

      # include nuenv dir in NU_LIB_DIRS
      const NU_LIB_DIRS = [
        "~/nuenv/"
      ]

      if ($env | get --optional XDG_STATE_HOME | is-empty) {
        $env.XDG_STATE_HOME = ("~/.local/state" | path expand)
      }

      ## Nix
      let default_nix_profile = "/nix/var/nix/profiles/default/"
      if ($default_nix_profile | path exists) {
        $env.PATH = $env.PATH | prepend $"($default_nix_profile)/bin" | uniq
      }

      let user_profile = $env.XDG_STATE_HOME | path join nix/profiles/profile | path expand
      if ($user_profile | path exists) {
        $env.PATH = $env.PATH | prepend $"($user_profile)/bin" | uniq
      }

      # add bun globals to path
      if ($env.HOME | path join ".bun/bin" | path exists) {
        $env.PATH = $env.PATH | prepend $"($env.HOME)/.bun/bin" | uniq
      }

      let pager_name = "bat"
      if (which $pager_name | is-empty) {
        print $"($pager_name) pager not found"
      } else {
        $env.PAGER = (which $pager_name | get path.0)
      }

      # zoxide init (generated by zoxide init nushell)
      source ~/.zoxide.nu

      overlay use default.nu
    '';
  };
}
