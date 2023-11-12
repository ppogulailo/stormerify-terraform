#!/bin/bash
sudo apt update -y &&
sudo apt install -y nginx
echo "<!DOCTYPE html>
      <html>
      	<head>
      		<title>My First Webpage</title>
      	</head>
      	<body>
      		<h1>Happy Coding</h1>
      		<p>Hello world!</p>
          <p>Here are my favorite animals:</p>
          <ul>
            <li>Lions</li>
            <li>Tigers</li>
            <li>Bears</li>
          </ul>
          <img src="https://happycoding.io/images/stanley-1.jpg" />
          <p>Learn more at <a href="https://happycoding.io">Happy Coding</a>!</p>
      	</body>
      </html>" > /var/www/html/index.html

