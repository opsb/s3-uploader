javascript: 
var doc="";
for(i=0;i<document.images.length;i++) {
	var image_url=document.images[i].src;
	doc+="<a href='http://<%= base_hostname %>?file="+escape(image_url)+"'><img src='"+image_url+"'></img></a>"
}
document.write(doc);
document.close();