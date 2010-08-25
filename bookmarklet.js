javascript: 
var doc="<head><style>h1{font-size:40px;padding-bottom:30px;margin:40px 0;border-bottom:1px solid #ccc;font-family:sans-serif;}</style></head><h1>Which image do you want?</h1>";
for(i=0;i<document.images.length;i++) {
	var image_url=document.images[i].src;
	doc+="<a href='http://<%= base_hostname %>?url="+escape(image_url)+"'><img src='"+image_url+"'></img></a>"
}
document.write(doc);
document.close();