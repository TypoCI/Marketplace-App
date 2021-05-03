<p align="center">
  <img src="https://typoci.com/images/typo-ci-logo.svg" alt="Typo CI Logo - It's a sword surrounded by brackets" width="96">
</p>

<h1 align="center">
  <a  target="_blank" rel="noopener noreferrer"  href="https://github.com/marketplace/typo-ci/">Typo CI</a>
</h1>

<p align="center">
Checks for spelling errors within commits by listening to webhooks from GitHub.
</p>

<p align="center">
  <a target="_blank" rel="noopener noreferrer" href="https://github.com/TypoCI/Marketplace-App/workflows/Tests/badge.svg">
    <img src="https://github.com/TypoCI/Marketplace-App/workflows/Tests/badge.svg" alt="RSpec" style="max-width:100%;">
  </a>
  <a target="_blank" rel="noopener noreferrer" href="https://github.com/TypoCI/Marketplace-App/workflows/Standard/badge.svg">
    <img src="https://github.com/TypoCI/Marketplace-App/workflows/Standard/badge.svg" alt="Linters" style="max-width:100%;">
  </a>
</p>


## Setup & Local Dev

```bash
docker-compose build
docker-compose run --rm web bin/setup
```

### Symlink puma-dev

This allows you run run the dashboard part of the app locally.

```bash
ln -s ~/.puma-dev/typoci .
echo "3000" > ~/.puma-dev/typoci
```

### Running locally

```bash
docker-compose up
```

### Running one off commands

Enter shell within the docker container with:

```bash
docker-compose run --rm --no-deps web bash
```

## Sources

* [Dictionaries source](https://cgit.freedesktop.org/libreoffice/dictionaries/)
* [CSpell Dictionaries](https://www.npmjs.com/package/@cspell/cspell-bundled-dicts)
