library(knitractive)
library(rexpect)
library(rlang)

engine <- start(name = "console",
          command = cmd_docker(image = "datasciencetoolbox/dsatcl2e",
                                volume = list2(!!here::here("images") := "/images",
                                               !!here::here("history") := "/history",
                                               !!here::here("data") := "/data.bak")),
          prompt = prompts$bash,
          session_width = 80,
          session_height = 16)

# "cd /usr/bin/dsutils && sudo git pull > /dev/null",
## " PS1='\\[$(tput bold)\\]$ \\[$(tput sgr0)\\]'",
## " PS2='\\[$(tput bold)\\]> \\[$(tput sgr0)\\]'",
setup <- c(" setopt HIST_IGNORE_SPACE",
           " export TERM=screen-256color",
           " export RIO_DPI=200",
           " export MANROFFOPT='-c'",
           " export MANPAGER=\"sh -c 'col -bx | /usr/bin/bat -plman --color=always'\"",
           " function csvlook {",
           "     /usr/local/bin/csvlook \"$@\" |",
           "     trim |",
           "     sed 's/- | -/──┼──/g;s/| -/├──/g;s/- |/──┤/;s/|/│/g;2s/-/─/g'",
           " }",
           " alias bat='bat --tabs 8 --paging never --theme \"Solarized (dark)\"'",
           " alias docker='echo'",
           " alias display='echo'",
           " sudo cp -r /data.bak /data",
           " sudo sudo chown -R dst:dst /data",
           " setopt interactivecomments",
           " eval $(dircolors -b)"
           )

send_lines(engine$session, setup, wait = TRUE)
engine$scroll(length(engine$session) - 1)

knitr::opts_chunk$set(escape = TRUE)
