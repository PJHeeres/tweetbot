import twitter4j.*;
import twitter4j.api.*;
import twitter4j.auth.*;
import twitter4j.conf.*;
import twitter4j.json.*;
import twitter4j.management.*;
import twitter4j.util.*;
import twitter4j.util.function.*;

import nl.tue.id.oocsi.*;
import nl.tue.id.oocsi.client.*;
import nl.tue.id.oocsi.client.behavior.*;
import nl.tue.id.oocsi.client.behavior.state.*;
import nl.tue.id.oocsi.client.data.*;
import nl.tue.id.oocsi.client.protocol.*;
import nl.tue.id.oocsi.client.services.*;
import nl.tue.id.oocsi.client.socket.*;

ConfigurationBuilder cb; 
Query query; 
TwitterFactory factory;
TwitterStreamFactory streamFactory;
Twitter twitter;
Status status;
StatusListener listener;
String OOCSItweet;
int maxTweetLength = 140;

void setup() {       
  // Setup credentials and Twitter instance
  cb = new ConfigurationBuilder();
  cb.setOAuthConsumerKey("nFxSHrom3pNdvmx2TvLRFdzAh");   
  cb.setOAuthConsumerSecret("kt45RjkQbKUHF3WqB9WoPHBlx4LbInutPraLD5k9DqcV3IjQYo");   
  cb.setOAuthAccessToken("831786162872262658-MZmxeFo3si5f7BToGLcmIZmf6qH9TI2");   
  cb.setOAuthAccessTokenSecret("CweKTuNzimS3l5jAZdOp41kSWqpEcZkZAIxe4G7fsdCze");
  Configuration conf = cb.build();
  factory = new TwitterFactory(conf);
  streamFactory = new TwitterStreamFactory(conf);
  twitter = factory.getInstance();
  
  // Setup OOCSI receiver
  OOCSI oocsi = new OOCSI(this, "TweetReceiver", "oocsi.id.tue.nl");
  oocsi.subscribe("tweetBot");
  
  // Setup listener for streaming API (stub)
  listener = new StatusListener() {
    
    public void onStatus(Status status) {
        handleStatus(status);
    }
    public void onDeletionNotice(StatusDeletionNotice statusDeletionNotice) {}
    public void onTrackLimitationNotice(int numberOfLimitedStatuses) {}
    public void onStallWarning(StallWarning stallWarning) {}
    public void onScrubGeo(long l1, long l2) {}
    public void onException(Exception ex) {
        ex.printStackTrace();
    }
  };
  setupStream();
  
} 

// Handler method for OOCSI events
void tweetBot(OOCSIEvent event) {
  OOCSItweet = event.getString("tweet", "Default tweet. Something went wrong.");
  if (OOCSItweet.length() > maxTweetLength) {
    println("Error: The status is too long to be posted.");
  }
  println("[OOSCI-receiver] Received a Tweet to be sent!");
  postStatus(OOCSItweet);
}

// Posting a status
void postStatus(String newStatus) {
  if(newStatus.length() > maxTweetLength) {
    println("Error: tweet was too long to send.");
  } else {
    try {
    status = twitter.updateStatus(newStatus);
    println("[Twitter4j-tweet] Status updated!");  
    } catch(Exception e) {
      println(e);
    }
  }
}

// Setup for streaming API
void setupStream() {
  TwitterStream twitterStream = streamFactory.getInstance();
  twitterStream.addListener(listener);
  twitterStream.filter("@Tweetbot_DBSU10");
}

// Method to handle our mentions (tweets to us)
void handleStatus(Status status) {
  println("[Twitter4j-stream] " + status.getUser().getName() + " : " + status.getText()); 
  
  String tweetText = status.getText().toLowerCase();
  if(tweetText.contains("deadline")) {
      String requestReply = "@" + status.getUser().getScreenName() + 
          " The next deadline, for handing in Challenge 1, is March 10, at 17:00!";
      postStatus(requestReply);
  }
  checkProduct("coffee", status);
  checkProduct("pizza", status);
}

// Method to check a tweet for a product order and handle it
void checkProduct(String product, Status status) {
  String tweetText = status.getText().toLowerCase();
  if(tweetText.contains("i want " + product) || tweetText.contains("order " + product)) {
    // For assignment 2: order product here
    confirmOrder(product, status);
  }
}

// Method to confirm a placed order to a Twitter user
void confirmOrder(String product, Status status) {
  String orderReply = "@" + status.getUser().getScreenName() + " Your " + product + " has been ordered!";
  postStatus(orderReply);
}