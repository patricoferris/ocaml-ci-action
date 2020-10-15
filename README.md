OCaml-CI Github Workflow
------------------------

🚧 WIP & Experimental 🧪

A Dockerfile for running `ocaml-ci-github` for generating large Github workflows for testing your OCaml repository. 

```
docker build . -t ocaml-ci 
docker run -v /my/cool/project:/var/lib/ocurrent/package -v /var/run/docker.sock:/var/run/docker.sock -p 8080:8080 -it ocaml-ci

🐳 ~ ocaml-ci-github --winmac --server /var/lib/ocurrent/package
```

The navigate to `localhost:8080` to see the build. Many docker images will be built... this may take some time... 


## Usage in a Workflow 

The best way to use this container is by running it on your package and then submitting a PR to update (or create) the main OCaml-CI workflow. 

```yaml
name: Github OCaml-CI Check
on:
  schedule:
    - cron: '* * * * *'
jobs:
  check-ci:
    runs-on: ubuntu-latest
    container:
      image: patricoferris/ocaml-ci-action:latest
      volumes: 
        - /var/run/docker.sock:/var/run/docker.sock
    steps:
      - run: git clone https://github.com/$GITHUB_REPOSITORY $GITHUB_WORKSPACE/package && cd $GITHUB_WORKSPACE/package && git checkout $GITHUB_SHA
      - name: OCaml-CI 
        run: ocaml-ci-github --winmac --exit $GITHUB_WORKSPACE/package
      - run: cat $GITHUB_WORKSPACE/package/.github/workflows/ocaml-ci.yml
      - run: |
          git config --global user.name 'Patrick Ferris'
          git config --global user.email 'patricoferris@users.noreply.github.com'
      - uses: peter-evans/create-pull-request@v3
        with: 
          path: package
          token: ${{ secrets.PAT }}
          commit-message: OCaml CI
          title: Check OCaml-CI 
          branch: ocaml-ci-check
          base: main
```

A couple of things to note:
  - It mounts the Docker daemon because OCaml-CI needs it to pull the Docker images 
  - It puts everything into a `package` directory 
  - You have to set the git user name and email 
  - This version uses [create-pull-request](https://github.com/peter-evans/create-pull-request) to make the PR. Note you will have to generate a personal access token (PAT) with access to modifying workflows (repo & workflow). You can then set a secret in the repo to be that. 