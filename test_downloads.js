// Simple script to test if download URLs work properly
// You can run this in the browser console on your deployed website

function testDownloadURLs() {
  const urls = [
    '/downloads/integrity-assistant-windows-protected.zip',
    '/downloads/integrity-assistant-macos-protected.zip',
    '/downloads/integrity-assistant-linux-protected.zip'
  ];

  console.log('=== TESTING DOWNLOAD URLS ===');
  
  urls.forEach(url => {
    fetch(url, { method: 'HEAD' })
      .then(response => {
        if (response.ok) {
          console.log(`✅ ${url} - OK (${response.status})`);
        } else {
          console.error(`❌ ${url} - FAILED (${response.status})`);
        }
      })
      .catch(error => {
        console.error(`❌ ${url} - ERROR: ${error.message}`);
      });
  });
}

// Run the test
testDownloadURLs();

// Note: You can paste this in your browser console on your deployed site
// to check if the download URLs are working properly 