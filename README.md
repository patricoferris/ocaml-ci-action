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
