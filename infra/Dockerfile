FROM gotenberg/gotenberg:8

USER root

RUN apt-get update -qq &&\
    DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends -t bookworm-backports libreoffice-l10n-en-us locales &&\
    sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen &&\
    locale-gen &&\
    # Cleanup.
    # Note: the Debian image does automatically a clean after each install thanks to a hook.
    # Therefore, there is no need for apt-get clean.
    # See https://stackoverflow.com/a/24417119/3248473.
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

USER gotenberg
