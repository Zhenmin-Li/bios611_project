FROM rocker/verse
MAINTAINER Zhenmin Li <zhenmin@live.unc.edu>
RUN R -e "install.packages(c('knitr','tidyr','dplyr','readr','ggplot2','tibble','stringr','gridExtra','scales','lubridate','ggrepel','reshape2','kableExtra','tm','wordcloud','wordcloud2','tidytext','textdata','broom','bit64'))"
RUN R -e "install.packages(c('rmarkdown','webshot','htmlwidgets'))"

RUN R -e "install.packages(c('tidyverse','gbm','gridExtra','ggfortify','factoextra','caret','e1071'))"

RUN apt update && apt-get install -y texlive*
RUN  sudo apt install texlive-latex-extra

Run apt-get install -y pandoc

RUN apt update -y && apt install -y python3-pip
RUN pip3 install jupyter jupyterlab
RUN pip3 install numpy pandas sklearn plotnine matplotlib pandasql bokeh