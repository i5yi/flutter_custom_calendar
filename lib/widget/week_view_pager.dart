import 'package:flutter/material.dart';
import 'package:flutter_custom_calendar/calendar_provider.dart';
import 'package:flutter_custom_calendar/configuration.dart';
import 'package:flutter_custom_calendar/controller.dart';
import 'package:flutter_custom_calendar/model/date_model.dart';
import 'package:flutter_custom_calendar/utils/LogUtil.dart';
import 'package:flutter_custom_calendar/widget/week_view.dart';
import 'package:provider/provider.dart';

class WeekViewPager extends StatefulWidget {
  const WeekViewPager({Key key}) : super(key: key);

  @override
  _WeekViewPagerState createState() => _WeekViewPagerState();
}

class _WeekViewPagerState extends State<WeekViewPager> with AutomaticKeepAliveClientMixin{
  int lastMonth; //保存上一个月份，不然不知道月份发生了变化
  CalendarProvider calendarProvider;

//  PageController newPageController;

  @override
  void initState() {
    LogUtil.log(TAG: this.runtimeType, message: "WeekViewPager initState");

    calendarProvider = Provider.of<CalendarProvider>(context, listen: false);

    lastMonth = calendarProvider.lastClickDateModel.month;
  }

  @override
  void dispose() {
    LogUtil.log(TAG: this.runtimeType, message: "WeekViewPager dispose");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    LogUtil.log(TAG: this.runtimeType, message: "WeekViewPager build");

    //    获取到当前的CalendarProvider对象,设置listen为false，不需要刷新
    CalendarProvider calendarProvider =
        Provider.of<CalendarProvider>(context, listen: false);
    CalendarConfiguration configuration =
        calendarProvider.calendarConfiguration;

    return Container(
      height: configuration.itemSize ?? MediaQuery.of(context).size.width / 7,
      child: PageView.builder(
        onPageChanged: (position) {
          if (calendarProvider.expandStatus.value == true) {
            return;
          }
          LogUtil.log(
              TAG: this.runtimeType,
              message: "WeekViewPager PageView onPageChanged:${position}");
//          周视图的变化
          DateModel firstDayOfWeek = configuration.weekList[position];
          int currentMonth = firstDayOfWeek.month;
          if (lastMonth != currentMonth) {
            LogUtil.log(
                TAG: this.runtimeType,
                message:
                    "WeekViewPager PageView monthChange:currentMonth:${currentMonth}");
            configuration.monthChange(
                firstDayOfWeek.year, firstDayOfWeek.month);
            lastMonth = currentMonth;
            if (calendarProvider.lastClickDateModel == null ||
                calendarProvider.lastClickDateModel.month != currentMonth) {
              DateModel temp = new DateModel();
              temp.year = firstDayOfWeek.year;
              temp.month = firstDayOfWeek.month;
              temp.day = firstDayOfWeek.day + 14;
              calendarProvider.lastClickDateModel = temp;
            }
          }
//          calendarProvider.lastClickDateModel = configuration.weekList[position]
//            ..day += 4;
        },
        controller: calendarProvider.calendarConfiguration.weekController,
        itemBuilder: (context, index) {
          DateModel dateModel = configuration.weekList[index];
          return new WeekView(
            year: dateModel.year,
            month: dateModel.month,
            firstDayOfWeek: dateModel,
            configuration: calendarProvider.calendarConfiguration,
          );
        },
        itemCount: configuration.weekList.length,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
