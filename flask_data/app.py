import html
import flask
import logging
from multiprocessing import Value

counter = Value('i', 0)
app = flask.Flask(__name__)
logging.basicConfig(filename='app.log',level=logging.DEBUG)


@app.route('/')
def index():
    with counter.get_lock():
        counter.value += 1
    response = f'Hello!<br>'
    response += f'This site is visited (since server reset) a total of {counter.value} times.<br>'
    logging.debug(f'Visit count {counter.value} belongs to {flask.request.remote_addr}')
    response += f'Your IP is {flask.request.remote_addr}.<p>'
    with open('/app/example_file_to_backup.txt','r') as f:
        file_contents = html.escape(f.read())
    response += f'Contents of auxilitary file:<br><textarea>{file_contents}</textarea>'
    return response


if __name__ == '__main__':
    app.run(host='127.0.0.1',port=5000,debug=True)