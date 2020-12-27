from flask import Flask, request
from flask_restful import Resource, Api

app = Flask(__name__)
api = Api(app)


dataBase = {'bus1':1, 'bus2':2,'bus3':3, 'bus5':5,'bus4':4,'2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6':5}
class TodoSimple(Resource):
    """
    POST request to look up uuid against which bus it might be

    return 1 or the correspoinding number after the word 'bus'
    
    """

    def post(self):
        #todos[todo_id] = request.form['data']
        try:
            print(request)
            print(request.form)
            return dataBase[request.form['data']]
        except KeyError:
            return None  

     

api.add_resource(TodoSimple, '/')

if __name__ == '__main__':
    app.run(debug=False, host='0.0.0.0')
    
