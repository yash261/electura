from flask import Flask,request,jsonify
import psycopg2
import base64
import numpy as np
from datetime import date
from datetime import datetime
import cv2
import os
app=Flask(__name__)
conn = psycopg2.connect(
    host="localhost",
    database="postgres",
    user="postgres",
    password="kooltheka")
cur = conn.cursor()

def createaccount(email,username,password,ip):
    cur.execute("SELECT * FROM logindata where email='{}'".format(email))
    row = cur.fetchone()
    if(row!=None):
        return {"status":404,"msg":"Account already exists"}
    cur.execute("SELECT * FROM ipaddress where ip='{}' and date='{}'".format(ip,str(date.today())))
    count=0
    row = cur.fetchone()
    while row is not None:
        count+=1
        row = cur.fetchone()
    if(count>=3):
        return {"status":404,"msg":"You are prohibited to register more than 3 times"}
    cur.execute("insert into ipaddress values('{}','{}')".format(ip,str(date.today())))
    cur.execute("insert into logindata values('{}','{}','{}')".format(email,username,password))
    conn.commit()
    return {"status":200}

def loginaccount(email,password):
    cur.execute("SELECT * FROM logindata where email='{}'".format(email))
    row = cur.fetchone()
    if(row==None):
        return {"status":404,"msg":"No Account"}
    cur.execute("SELECT * FROM logindata where email='{}' and password='{}'".format(email,password))
    row = cur.fetchone()
    if(row==None):
        return {"status":404,"msg":"Wrong Password"}
    return {"status":200}


@app.route('/createaccount',methods=['GET'])
def register():
    email=str(request.args['email'])
    username=str(request.args['username'])
    password=str(request.args['password'])
    ip=str(request.args['ip'])
    return createaccount(email,username,password,ip)

@app.route('/login',methods=['GET'])
def login():
    email=str(request.args['email'])
    password=str(request.args['password'])
    print(email,password)
    return loginaccount(email,password)

@app.route('/file',methods=['POST'])
def file():
    user = request.files['picture'].read()
    name=request.form['name']
    email=request.form['email']
    nparr=np.fromstring(user,np.uint8)
    img=cv2.imdecode(nparr,cv2.IMREAD_COLOR)
    loc=os.path.join('D:\data',email+name)
    cur.execute("SELECT * FROM datafiles where file='{}' and email='{}'".format(email,name))
    row = cur.fetchone()
    if(row!=None):
        return "Same name exists"
    cv2.imwrite(loc,img)
    size=os.stat(loc).st_size
    cur.execute("insert into datafiles values('{}','{}','{}','{}')".format(name,loc,size,email))
    conn.commit()
    with open(loc, "rb") as imageFile:
        str = base64.b64encode(imageFile.read())
    return "Uploaded"

@app.route('/getfiles',methods=['GET'])
def getFiles():
    email=str(request.args['email'])
    cur.execute("select file from datafiles where email='{}'".format(email))
    row = cur.fetchone()
    result=dict()
    while row is not None:
        print(row)
        result["files"]=result.get("files",[])+list(row)
        row = cur.fetchone()
    return result
if __name__ =="__main__":
    app.run(host="192.168.1.209")
    conn.close()