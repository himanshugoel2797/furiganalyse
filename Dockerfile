FROM python:3.12-bookworm
LABEL org.opencontainers.image.authors="itsupera@gmail.com"

# switch to root user to use apt-get
USER root

# Install the MeCab runtime. The dictionary is provided by the bundled
# `unidic-lite` Python package (a transitive dep of the furigana fork below),
# so we no longer install mecab-ipadic / mecab-ipadic-neologd here.
RUN apt-get update && apt-get install -y \
  git curl file python3-poetry \
  mecab=0.996-14+b14 libmecab-dev=0.996-14+b14 \
  sudo \
  pandoc calibre \
  && rm -rf /var/lib/apt/lists/*

# MeCab on Debian looks for /usr/local/etc/mecabrc; the apt package only
# installs /etc/mecabrc, so mirror it. The furigana library passes -d
# <unidic_lite.DICDIR> at Tagger construction time, so the dicdir entry in
# this file is irrelevant for our use, but MeCab refuses to start without it.
RUN cp /etc/mecabrc /usr/local/etc/mecabrc

# Setup our dependencies
WORKDIR /workdir
ADD README.md .
ADD pyproject.toml .
ADD poetry.lock .
# Little optimization in order to install our dependencies before copying the source
RUN mkdir furiganalyse && touch furiganalyse/__init__.py
RUN pip3 install -e .

# Add the sources
ADD furiganalyse furiganalyse
ADD assets assets

EXPOSE 5000

ENTRYPOINT ["uvicorn", "furiganalyse.app:app", "--workers", "10", "--host", "0.0.0.0", "--port", "5000"]
