/*

	About: timestamp manipulation functions

*/

#if defined _time_t_included
	#endinput
#endif

#define _time_t_included


/*
	Defines
*/

#define YEAR0           1900            /* the first year */
#define EPOCH_YR        1970            /* EPOCH = Jan 1 1970 00:00:00 */
#define SECS_DAY        (24 * 60 * 60)
#define LEAPYEAR(%0)    (!((%0) % 4) && (((%0) % 100) || !((%0) % 400)))
#define YEARSIZE(%0)    (LEAPYEAR(%0) ? 366 : 365)
#define TIME_MAX        cellmax

/*
	Vars
*/
static const _ytab[2][12] = {
	{ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 },
	{ 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
};

/*
	About: gmtime - convert the calendar time into broken down time
	Author: Minix Developers
	Convert to Pawn: ziggi
*/

stock gmtime(timestamp, &year = EPOCH_YR, &month = 1, &day = 1, &hour = 0, &minute = 0, &second = 0)
{
	static dayclock;

	year = EPOCH_YR;
	dayclock = timestamp % SECS_DAY;
	day = timestamp / SECS_DAY;

	second = dayclock % 60;
	minute = (dayclock % 3600) / 60;
	hour = dayclock / 3600;

	while (day >= YEARSIZE(year)) {
		day -= YEARSIZE(year);
		year++;
	}

	month = 0;

	while (day >= _ytab[LEAPYEAR(year)][month]) {
		day -= _ytab[LEAPYEAR(year)][month];
		month++;
	}

	day++;
	month++;
}

/*
	About: mktime - convert local time into calendar time
	Author: Minix Developers
	Convert to Pawn: ziggi
*/

stock mktime(year = EPOCH_YR, month = 1, day = 1, hour = 0, minute = 0, second = 0)
{
	static mday, overflow, yday, mon;

	minute += second / 60;
	second %= 60;
	if (second < 0) {
		second += 60;
		minute--;
	}

	hour += minute / 60;
	minute = minute % 60;
	if (minute < 0) {
		minute += 60;
		hour--;
	}

	mday = hour / 24;
	hour = hour % 24;
	if (hour < 0) {
		hour += 24;
		mday--;
	}

	month--;
	year += month / 12;
	month %= 12;
	if (month < 0) {
		month += 12;
		year--;
	}

	mday += (day - 1);
	while (mday < 0) {
		if(--month < 0) {
			year--;
			month = 11;
		}
		mday += _ytab[LEAPYEAR(year)][month];
	}

	while (mday >= _ytab[LEAPYEAR(year)][month]) {
		mday -= _ytab[LEAPYEAR(year)][month];
		if (++month == 12) {
			month = 0;
			year++;
		}
	}
	day = mday + 1;

	if (year < EPOCH_YR) {
		return -1;
	}

	overflow = 0;

	if (cellmax / 365 < year - EPOCH_YR) {
		overflow++;
	}

	mday = (year - EPOCH_YR) * 365;
	if (cellmax - mday < (year - EPOCH_YR) / 4 + 1) {
		overflow++;
	}

	mday += (year - EPOCH_YR) / 4 + _:((year % 4) && year % 4 < EPOCH_YR % 4);
	mday -= (year - EPOCH_YR) / 100 + _:((year % 100) && year % 100 < EPOCH_YR % 100);
	mday += (year - EPOCH_YR) / 400 + _:((year % 400) && year % 400 < EPOCH_YR % 400);

	yday = 0;
	mon = 0;
	while (mon < month) {
		yday += _ytab[LEAPYEAR(year)][mon];
		mon++;
	}

	yday += (day - 1);
	if (mday + yday < 0) {
		overflow++;
	}

	mday += yday;

	new seconds = ((hour * 60) + minute) * 60 + second;
	if ((TIME_MAX - seconds) / SECS_DAY < mday) {
		overflow++;
	}

	seconds += mday * SECS_DAY;

	if (overflow) {
		return -1;
	}

	return seconds;
}
