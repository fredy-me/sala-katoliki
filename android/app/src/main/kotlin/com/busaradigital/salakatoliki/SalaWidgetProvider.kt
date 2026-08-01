package com.busaradigital.salakatoliki

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class SalaWidgetProvider : HomeWidgetProvider() {

  override fun onUpdate(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetIds: IntArray,
      widgetData: SharedPreferences,
  ) {
    val views = RemoteViews(context.packageName, R.layout.sala_widget_layout)

    views.setTextViewText(
        R.id.widget_label,
        widgetData.getString(KEY_LABEL, DEFAULT_LABEL),
    )
    views.setTextViewText(
        R.id.widget_title,
        widgetData.getString(KEY_TITLE, DEFAULT_TITLE),
    )
    views.setTextViewText(
        R.id.widget_snippet,
        widgetData.getString(KEY_SNIPPET, DEFAULT_SNIPPET),
    )

    val prayerId = widgetData.getString(KEY_PRAYER_ID, null)
    val deepLink = prayerId?.let { Uri.parse("/prayers/$it") }
    views.setOnClickPendingIntent(
        R.id.widget_root,
        HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, deepLink),
    )

    appWidgetManager.updateAppWidget(appWidgetIds, views)
  }

  companion object {
    const val KEY_TITLE = "widget_prayer_title"
    const val KEY_SNIPPET = "widget_prayer_snippet"
    const val KEY_LABEL = "widget_prayer_label"
    const val KEY_PRAYER_ID = "widget_prayer_id"

    private const val DEFAULT_LABEL = "TODAY'S PRAYER"
    private const val DEFAULT_TITLE = "Sala Katoliki"
    private const val DEFAULT_SNIPPET = "Open the app to view today's prayer."
  }
}
