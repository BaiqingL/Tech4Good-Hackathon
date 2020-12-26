
from flask import Flask, request
from flask_restful import Resource, Api

app = Flask(__name__)
api = Api(app)


dataBase = {'bus1':1, 'bus2':2,'bus3':3, 'bus5':5,'bus4':4}
class TodoSimple(Resource):
    """
    curl http://localhost:5000/todo -d "data=bus1" -X PUT

    return 1 or the correspoinding number after the word 'bus'
    
    """

    def put(self, todo_id):
        #todos[todo_id] = request.form['data']
        try:
            return dataBase[request.form['data']]
        except KeyError:
            return None  

     

api.add_resource(TodoSimple, '/<string:todo_id>')

if __name__ == '__main__':
    app.run(debug=False)
