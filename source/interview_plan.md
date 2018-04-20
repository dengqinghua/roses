Interview Plan
==============

DATE: 2018-02-24

Prepare for my next job interview as a programmer dog.

After reading this guide, you will know:

* Books to read
* Blogs to write
* Interview Resume to prepare
* Time intervals to estimate

--------------------------------------------------------------------------------

Books
-----
### Data Structures and Algorithm Analysis
- [Grokking Algorithms: An illustrated guide for programmers and other curious people](https://www.amazon.com/Grokking-Algorithms-illustrated-programmers-curious/dp/1617292230/ref=sr_1_1?ie=UTF8&qid=1519440970&sr=8-1&keywords=Grokking+Algorithms)
- [Data Structures and Algorithm Analysis in Java](https://www.amazon.com/Data-Structures-Algorithm-Analysis-Java/dp/0132576279/ref=sr_1_1?s=books&ie=UTF8&qid=1519441056&sr=1-1&keywords=Data+Structures+Algorithm+Analysis+java)

### JVM
- [Red Book](https://www.amazon.cn/dp/B073LZD7KB/ref=sr_1_3?ie=UTF8&qid=1519441214&sr=8-3&keywords=jvm)
- [White Book](https://www.amazon.cn/dp/B00D2ID4PK/ref=sr_1_1?ie=UTF8&qid=1519441214&sr=8-1&keywords=jvm)
- [JVM spec](https://docs.oracle.com/javase/specs/jvms/se8/jvms8.pdf)

### Computer System
- [Computer Systems: A Programmer's Perspective](https://www.amazon.com/Computer-Systems-Programmers-Perspective-2nd/dp/0136108040/ref=sr_1_3?s=books&ie=UTF8&qid=1519441490&sr=1-3&keywords=Computer+Systems+A+Programmer%27s+Perspective)
- [Easy to Learn TCP/IP](https://www.amazon.cn/dp/B00DMS9990/ref=sr_1_1?ie=UTF8&qid=1519441861&sr=8-1&keywords=%E5%9B%BE%E8%A7%A3tcp%2Fip)
- [TCP/IP Illustrated, Volume 1: The Protocols](https://www.amazon.com/TCP-Illustrated-Protocols-Addison-Wesley-Professional/dp/0321336313/ref=sr_1_1?s=books&ie=UTF8&qid=1519441546&sr=1-1&keywords=TCP+IP)

NOTE: Memorize [W.Richard Stevens](https://en.wikipedia.org/wiki/W._Richard_Stevens)

Blogs
-----
### Badge System
Use Sql Memory Engine to Solve frontend badge Problems

- Use [calcite](https://calcite.apache.org/) to run memory databases
- Combine condition, rule, sqlAnalyze, badge and badgeView
- How source data prepared
- Optimize sqls, connections, prepare statements and logs

### CPC(Cost Per Click) System
Use [sidekiq](https://sidekiq.org/) to implement realtime deducting when page product was clicked.

- Flow: clicks collection, clicks gathering to ES, clicks deducting
- Use DataStructures to prevent duplicate deducting
- Crontab jobs to check if clicks were not deducted by network problem
- Best practice for rededucting clciks when clicks collection was dreadly wrong

### Visitor Based Workflow Engine
Use visual page to config all flows, spy every flow running, gathering the running to diagnose performance.

- Why workflow engine
- Pros and cons of workflow
- Visitor pattern and kafka gathering running infos

### Knowledge Trees
Web knowledge trees based on Rails.

- Web Framework: Ruby On Rails (Maybe Spring should be invovled too)
- Queues
  + SingleSystem Queue based on sidekiq
  + Multisystem Queue based on kafak
- RPC
  + Thrift RPC
  + HTTP API
- Passenger Server
- Nginx, Vanish, CDN and Page Cache
- CSS/JS, Vue
- MySQL
- ES

Interview Resume
----------------
1. Add more projects and blogs
2. Read books like [Cracking the Coding Interview](https://www.amazon.com/s/?ie=UTF8&keywords=cracking+the+coding+interviews&tag=googhydr-20&index=aps&hvadid=241666619915&hvpos=1t1&hvnetw=g&hvrand=10469926032186193730&hvpone=&hvptwo=&hvqmt=e&hvdev=c&hvdvcmdl=&hvlocint=&hvlocphy=9031956&hvtargid=kwd-302976838943&ref=pd_sl_4n1d01w4zj_e)

Time Estimation
---------------
### Books
- Data Structures and Algorithms: 2 weeks
- JVM: 2 weeks
- Computer System: 1 month

### Blogs
1 week for each blog

### Interview Resume
At the forth week
