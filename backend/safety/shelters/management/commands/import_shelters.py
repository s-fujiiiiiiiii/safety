import csv
from django.core.management.base import BaseCommand
from shelters.models import Shelter

class Command(BaseCommand):
    help = 'CSVから避難所データを登録する'

    def handle(self, *args, **options):
        with open('shelters_hakata.csv', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                Shelter.objects.update_or_create(
                    name=row['name'],
                    defaults={
                        'latitude': row['latitude'],
                        'longitude': row['longitude'],
                        'address': row['address'],
                    }
                )
        self.stdout.write(self.style.SUCCESS('✅ 避難所データ登録完了'))
