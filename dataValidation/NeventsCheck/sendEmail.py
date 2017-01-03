### Tool to send email. Can import directly in a python script or use standalone
###  the command line.
from email.mime.text import MIMEText
import email.Utils
import smtplib

def sendEmail(emailList, sub, msg):
    #emailList = ["robroy.fletcher@gmail.com"]

    for emailID in emailList:
        try:
            ## setup the user to send email from
            passwd = "Atlas for life"
            user = "MxAODValidation@gmail.com"

            ## Setup the message details needed by the server.
            FROM = "MxAODValidation@gmail.com"
            TO = emailID
            message = msg
            msg = MIMEText(message)
            msg["Subject"] = sub
            msg["Message-id"] = email.Utils.make_msgid()
            msg["From"] = FROM
            msg["To"] = TO

            ## Start the server, login and send the email.
            host = "smtp.gmail.com"
            server = smtplib.SMTP(host, 587)
            server.starttls()
            server.login(user, passwd)
            server.sendmail(FROM, TO, msg.as_string())
            server.quit()

        except Exception, e:
            print e

if __name__=='__main__':
    import argparse

    parser = argparse.ArgumentParser(description="Send an email from the command line.")

    parser.add_argument('--to', required=True, default='robflet@sas.upenn.edu')
    parser.add_argument('--sub', default='dataValidation')
    parser.add_argument('--msg', required=True)
    args = parser.parse_args()

    sendEmail(args.to, args.sub, args.msg)
