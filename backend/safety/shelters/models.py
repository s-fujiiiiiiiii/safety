from django.db import models

class Shelter(models.Model):
    name = models.CharField(max_length=200)
    latitude = models.FloatField()
    longitude = models.FloatField()
    address = models.CharField(max_length=300)

    def __str__(self):
        return self.name
