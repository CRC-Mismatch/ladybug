from django.contrib import admin
from django.db import models

admin.site.register(models.StockItem)
admin.site.register(models.SourceItem)
admin.site.register(models.SalesChannel)
admin.site.register(models.Sale)
admin.site.register(models.StockSale)

# Register your models here.
