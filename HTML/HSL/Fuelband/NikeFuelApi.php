<?php

class NikeplusFuelbandAPI {

  /**
   * @var string
   * The email of the main account.
   */
  private $email = '';

  /**
   * @var string
   * The password of the main account.
   */
  private $password = '';

  /**
   * @var string
   * The username of the main account
   */
  private $username = '';

  /**
   * @var bool
   * Flag that indicates if the current object is authenticated or not.
   */
  private $authenticated = FALSE;

  /**
   * @const
   * The path where to store the cookie information. The apache user must have
   * write access to that file.
   */
  const cookie_file = '/tmp/cookiefile';
  /**
   * @const
   * The base url path of the profiles.
   */
  const base_profile_url = 'http://nikeplus.nike.com/plus/';

  public function __construct($email, $password) {
    $this->email = $email;
    $this->password = $password;
  }

  /**
   * @return bool
   *   Checks if the user is authenticated or not.
   */
  public function isAuthenticated() {
    return $this->authenticated;
  }

  /**
   * Logs in the user.
   */
  public function login() {
    // If already authenticated, skip it.
    if ($this->isAuthenticated()) {
      return;
    }
    $curl = curl_init();
    curl_setopt($curl, CURLOPT_RETURNTRANSFER, TRUE);
    curl_setopt($curl, CURLOPT_USERAGENT, "Mozilla/4.0 (compatible; MSIE 5.01; Windows NT 5.0)");
    curl_setopt($curl, CURLOPT_URL, 'https://secure-nikeplus.nike.com/nsl/services/user/login?app=b31990e7-8583-4251-808f-9dc67b40f5d2&format=json&contentType=plaintext');
    curl_setopt($curl, CURLOPT_POST, 1);
    curl_setopt($curl, CURLOPT_POSTFIELDS, 'email=' . $this->email . '&password=' . $this->password);
    curl_setopt($curl, CURLOPT_COOKIEJAR, NikeplusFuelbandAPI::cookie_file);
    curl_setopt($curl, CURLOPT_SSL_VERIFYHOST, 0);
    curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, 0);

    $result = curl_exec($curl);
    $curl_errno = curl_errno($curl);
    $curl_error = curl_error($curl);
    curl_close($curl);
    if ($curl_errno == 0) {
      $result = json_decode($result);
      $this->authenticated = TRUE;
      $this->username = $result->serviceResponse->body->User->screenName;
    }
    else {
     return "0";
    }
  }

public function getMyLastFullActivity() {
   // Make sure we are logged in.
    $this->login();
    // If not yet authenticated, something is wrong, so just return FALSE.
    // The reason why the user is not authenticated should be handled by the
    // login method.
    if (!$this->isAuthenticated()){
		return FALSE;
    }
    // Build URL for request
    $url = NikeplusFuelbandAPI::base_profile_url . 'fuelband/home/' . $this->username;

    $html = $this->request($url);
    //print_r($html);

    $activities = $this->searchActivity($html, 'latest_activity_detail');
   	return ($activities->dailyGoalInfo);
 }
 
  /**
   * Parses an html string to return the details of a specific activity.
   *
   * @param string $html
   *   The html to search in.
   * @param string $activity
   *   What activity (javascript object name) to search for,
   *   'window.np.' will be prefixed.
   * @return object
   *   A object with the details of the activity.
   */
  private function searchActivity($html, $activity) {
    // @todo: refactor this code.
    //print_r($html);
    $words = explode('window.np.' . $activity . ' = ', $html);
    $words = explode('</script>', $words[1]);
    // Remove the ";" from the end of the string.
    $words[0] = substr($words[0], 0, strlen($words[0]) - 2);
    return json_decode($words[0]);
    
  }

  /**
   * Performs a request on the nikeplus site.
   *
   * @param string $url
   *   The url used in the request.
   * @return bool|string
   *   If the request was successful,returns the html. Otherwise, returns FALSE.
   */
 
  private function request($url) {
    // @todo: should we try to authenticate the user if it is not yet
    // authenticated?
    if (!$this->authenticated) {
      return FALSE;
    }
    $curl = curl_init();
    curl_setopt($curl, CURLOPT_RETURNTRANSFER, TRUE);
    curl_setopt($curl, CURLOPT_FOLLOWLOCATION, TRUE);
    curl_setopt($curl, CURLOPT_USERAGENT, "Mozilla/4.0 (compatible; MSIE 5.01; Windows NT 5.0)");
    curl_setopt($curl, CURLOPT_URL, $url);
    curl_setopt($curl, CURLOPT_COOKIEJAR, NikeplusFuelbandAPI::cookie_file);
    curl_setopt($curl, CURLOPT_COOKIEFILE, NikeplusFuelbandAPI::cookie_file);
    $result = curl_exec($curl);
    // @todo: handle errors.
    $curl_errno = curl_errno($curl);
    $curl_error = curl_error($curl);
    curl_close($curl);
    if ($curl_errno == 0) {
      return $result;
    }
    else {
      // @todo: handle errors here?
      return FALSE;
    }
  }

}
