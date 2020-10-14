# Based on https://github.com/ocurrent/ocaml-ci/blob/master/Dockerfile
FROM ocurrent/opam:debian-10-ocaml-4.10 AS build
RUN sudo apt-get update && sudo apt-get install libev-dev capnproto m4 pkg-config libsqlite3-dev libgmp-dev -y --no-install-recommends
RUN cd ~/opam-repository && git pull origin -q master && git reset --hard 6be4f42a8ad6d8d8bfcd0a368c590e425a4b21c4 && opam update
RUN git clone --recursive https://github.com/patricoferris/ocaml-ci -b github-workflows
WORKDIR /home/opam/ocaml-ci
RUN opam pin add -yn github-workflow git+https://github.com/patricoferris/opam-github-workflow.git#3f05bfaf406511e77595a63f9ba85c0d31a1369a && \
  opam pin add -yn obuilder-spec "./ocluster/obuilder" && \
  opam pin add -yn obuilder "./ocluster/obuilder" && \
  opam pin add -yn current_ansi.dev "./ocurrent" && \
  opam pin add -yn current_docker.dev "./ocurrent" && \
  opam pin add -yn current_github.dev "./ocurrent" && \
  opam pin add -yn current_git.dev "./ocurrent" && \
  opam pin add -yn current_incr.dev "./ocurrent" && \
  opam pin add -yn current.dev "./ocurrent" && \
  opam pin add -yn current_rpc.dev "./ocurrent" && \
  opam pin add -yn current_slack.dev "./ocurrent" && \
  opam pin add -yn current_web.dev "./ocurrent" && \
  opam pin add -yn ocluster-api.dev "./ocluster"

RUN opam install -y --deps-only .
# ADD --chown=opam . .
RUN opam config exec -- dune build ./_build/install/default/bin/ocaml-ci-service
RUN opam config exec -- dune build ./_build/install/default/bin/ocaml-ci-github

FROM debian:10
RUN apt-get update && apt-get install libev4 openssh-client curl gnupg2 dumb-init git graphviz libsqlite3-dev ca-certificates netbase -y --no-install-recommends
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN echo 'deb [arch=amd64] https://download.docker.com/linux/debian buster stable' >> /etc/apt/sources.list
RUN apt-get update && apt-get install docker-ce -y --no-install-recommends
WORKDIR /var/lib/ocurrent
ENV OCAMLRUNPARAM=a=2
# Enable experimental for docker manifest support
EXPOSE 8080
ENV DOCKER_CLI_EXPERIMENTAL=enabled
COPY --from=build /home/opam/ocaml-ci/_build/install/default/bin/ocaml-ci-service \
  /home/opam/ocaml-ci/_build/install/default/bin/ocaml-ci-solver \
  /home/opam/ocaml-ci/_build/install/default/bin/ocaml-ci-github \
  /usr/local/bin/