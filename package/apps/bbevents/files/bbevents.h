/*
 * bbevents.h
 *
 *  Created on: Apr 5, 2016
 *      Author: yuyue
 */

#ifndef BBEVENTS_H_
#define BBEVENTS_H_

#define INTERVAL_DECLARE 2.0
//#define BBEVENT_DEBUG
#define BBEVENT_LOG

#ifdef BBEVENT_DEBUG
# define BBPRINT(...) printf(__VA_ARGS__)
#elif defined(BBEVENT_LOG)
# define BBPRINT(format, args...)  \
do{  \
  FILE *fp = NULL;  \
  if((fp = fopen("/tmp/bbevents.txt", "w+")) != NULL)  \
  {  \
    fprintf(fp, format, ##args);  \
    fclose(fp);  \
  }  \
}while(0)
#endif

#endif /* BBEVENTS_H_ */
