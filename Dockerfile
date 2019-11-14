FROM ethereum/client-go:stable

RUN mkdir /hart && mkdir -p /hart-file/cred && apk add curl && mkdir /etc/periodic/1min
ADD genesis.json /hart-file/genesis.json
ADD sealer /hart-file/sealer

ADD join /usr/local/bin/join
ADD account /usr/local/bin/account
ADD vote /usr/local/bin/vote
ADD unvote /usr/local/bin/unvote
ADD clear /usr/local/bin/clear
ADD monitoring /etc/periodic/1min/monitoring

RUN chmod a+x /usr/local/bin/join && chmod a+x /usr/local/bin/account && chmod a+x /usr/local/bin/vote && chmod a+x /usr/local/bin/unvote && chmod a+x /usr/local/bin/clear && chmod a+x /etc/periodic/1min/monitoring
RUN echo "*       *       *       *       *       run-parts /etc/periodic/1min" >> /etc/crontabs/root

EXPOSE 8545 8546 30303

ENTRYPOINT ["/bin/sh", "/hart-file/sealer"]