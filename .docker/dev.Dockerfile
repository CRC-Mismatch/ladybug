FROM python:3-slim
ARG USER_TERM
ENV TERM=${USER_TERM}
ARG PROJECT_PATH=/project
ENV PROJECT_PATH=${PROJECT_PATH}
RUN set -ex; \
    apt-get update -qq; \
    apt-get install --no-install-recommends --no-install-suggests -y \
        colorize \
        command-not-found \
        lsb-release \
        git \
        gnupg \
        gpg \
        gpg-agent \
        ssh-client \
        sudo \
        pipx \
        unzip \
        wget; \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers; \
    useradd -m -s /bin/bash -G sudo app; \
    chown -R app:app "/home/app"; \
    mkdir ${PROJECT_PATH}; \
    chown -R app:app ${PROJECT_PATH};

USER app

RUN set -ex; \
    pipx install poetry; \
    pipx install --suffix=@stable poetry==1.8.2; \
    pipx ensurepath;

ARG ZSHTHEME
RUN set -ex; \
    export PATH=/home/app/.local/bin:$PATH; \
    if [ "${ZSHTHEME}" = "powerlevel10k/powerlevel10k" ] || [ -z "${ZSHTHEME}" ]; then export THEME="maran"; else export THEME="${ZSHTHEME}"; fi; \
    sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.5/zsh-in-docker.sh)" -- -p debian -p sudo -p command-not-found -p colorize -p poetry -p poetry@stable -p python -p zsh-pipx -t "$THEME" -a "setopt no_nomatch"; \
    sudo chsh -s /usr/bin/zsh app; \
    sed -i '1s~^~export PATH="$PATH:/home/app/.local/bin"\n~' ~/.zshrc; \
    mkdir -p ~/.oh-my-zsh/custom/plugins/poetry; \
    poetry -n completions zsh > ~/.oh-my-zsh/custom/plugins/poetry/_poetry; \
    mkdir -p ~/.oh-my-zsh/custom/plugins/poetry@stable; \
    poetry@stable -n completions zsh > ~/.oh-my-zsh/custom/plugins/poetry@stable/_poetry@stable; \
    sed -Ei 's/^#compdef poetry$/#compdef poetry@stable/gm' ~/.oh-my-zsh/custom/plugins/poetry@stable/_poetry@stable; \
    git clone https://github.com/thuandt/zsh-pipx ~/.oh-my-zsh/custom/plugins/zsh-pipx; \
    touch ~/.zsh_history

RUN set -ex; \
    /usr/bin/zsh -c "pipx ensurepath";

WORKDIR $PROJECT_PATH
EXPOSE 8000