from apscheduler.schedulers.blocking import BlockingScheduler
import EPN

sched = BlockingScheduler()



#ERP rate
@sched.scheduled_job('interval',seconds=10)
def traffic_incident():
    EPN.main_function()



sched.start()