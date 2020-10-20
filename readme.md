# Sentiment Analysis of Trump's Tweets before election

Running the environment:

```
docker build -< Dockerfile
```

# Make Targets

You can directly run the make file

```
make
```

Or view the figures

```
make figures/top20.png
make figures/bigramms.png
make figures/mostused.png
make figures/wordcloud1.png
make figures/wordcloud2.png
make figures/time_bing.png
```

Or generate the reports
```
make report.pdf
```

You can view the dataset (Trump's tweets) in "source_data" and project proposal in "proposal"