"""This module tests homepage and aboutpage modules"""

from django.test import SimpleTestCase, Client


class ViewTests(SimpleTestCase):
    """This is a simple unittest class to test django page functionality"""
    def test_home_page_response(self):
        """Tests homepage response functionality"""
        client = Client()
        resp = client.get('/')
        self.assertEqual(resp.status_code, 200)
        self.assertContains(resp, 'Hello, world!')
        self.assertContains(resp, 'About')

    def test_about_page_response(self):
        """Tests aboutpage response functionality"""
        client = Client()
        resp = client.get('/about/')
        self.assertEqual(resp.status_code, 200)
        self.assertContains(resp, 'This is an example')
        self.assertContains(resp, 'Home')
