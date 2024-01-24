import time
import random

from django.contrib.auth.models import User
from hello.serializers import UserSerializer
from rest_framework import generics


class UserList(generics.ListCreateAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer

    def get(self, request, *args, **kwargs):
        time.sleep(random.random() * 5)
        return super().get(request, *args, **kwargs)
