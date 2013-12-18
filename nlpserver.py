from flask import Flask,request
import nltk
from collections import Counter
app = Flask(__name__)

word_frequencies = {}
word_frequencies['en'] = Counter(nltk.corpus.brown.words())

print word_frequencies['en']

@app.route('/wordfreq')
def wordfreq():
  if 'word' not in request.args:
  	return 'need word'
  word = request.args['word']
  lang = 'en'
  if 'lang' in request.args:
  	lang = request.args['lang']
  if word not in word_frequencies[lang]:
  	return '0'
  return str(word_frequencies[lang][word])

if __name__ == '__main__':
  app.run(port=5000, debug=True)
