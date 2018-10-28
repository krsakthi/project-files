from flask import Flask, jsonify, request
from flask_pymongo import PyMongo

app = Flask(__name__)

### MongoDB Connection ###
app.config['MONGO_DBNAME'] = 'guardian_au'
app.config['MONGO_URI'] = 'mongodb://localhost:27017/guardian_au'

mongo = PyMongo(app)

### API Get request to query on article_title field ###
@app.route('/news_articles/<keyword>', methods=['GET'])
def get_news_articles(keyword):
    news_articles = mongo.db.news_articles

##Query##
    q = news_articles.find_one({'article_title': keyword})

##Exception Handling##
    if q:
        output = {'article_title' : q['article_title'], 'article_headline' : q['article_headline'], 'article_author' : q['article_author'], 'article_url' : q['article_url'] }
    else:
        output = 'No results found'

    return jsonify({'Articles' : output})

if __name__ == '__main__':
    app.run(debug=True)


####Sample Success API calls####
##127.0.0.1:5000/news_articles/Land of plenty
##127.0.0.1:5000/news_articles/Sportswatch