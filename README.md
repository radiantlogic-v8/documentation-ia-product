# Documentation iGRCanalytics

## Introduction

This repository holds the documentation for the core product of Identity Analytics: iGRCAnalytics .  
The documentation is used as an input to build the documentation https://developer.radiantlogic.com/

## Repository Structure

The repository is structured such as each branch corresponds to the documentation of a specific version.  

## Gatsby .env

To use the repository to build locally in Gatsby use the following code in the `GATSBY_DEPLOY_REPOS` parameter of the `.env` file (some adaptation may be necessary):

```sh
GATSBY_DEPLOY_REPOS='
[
  {
    "name": "ia",
    "displayName": "iGRCanlytics",
    "description": "This guide provides the technical documentation for iGRCanalytics",
        "links": [
      {
        "text": "iGRCanalytics",
        "href": "/ia/descartes/#0"
      }
    ],
    "remote": "https://github.com/radiantlogic-v8/documentation-ia-product.git",
    "patterns": [
      "home-pages/**",
      "documentation/**"
    ],
    "deployBranches": [
      {
        "name": "descartes",
        "displayName": "Descartes"
      }
    ]
  }
]
'
'
```
