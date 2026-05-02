# Migrated from dot_config/starship.toml
{ ... }:

{
  programs.starship = {
    enable = true;
    settings = {
      # The original TOML used `\` as line-continuation (removing newlines).
      # The actual format value is one concatenated line, with a newline only
      # before $os (matching the original triple-quoted TOML).
      format = "$all$fill$time$line_break$jobs$battery$status\${custom.jj}\n$os$container$shell\n";

      fill.symbol = " ";

      time = {
        disabled = false;
        format = "[$time]($style) ";
      };

      custom.jj = {
        when = "jj-starship detect";
        shell = ["jj-starship"];
        format = "$output ";
      };
    };
  };
}
