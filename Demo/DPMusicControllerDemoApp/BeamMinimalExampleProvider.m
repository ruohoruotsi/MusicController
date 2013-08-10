//
//  BeamMinimalExampleProvider.m
//  Part of BeamMusicPlayerViewController (license: New BSD)
//  -> https://github.com/BeamApp/MusicPlayerViewController
//
//  Created by Moritz Haarmann on 01.06.12.
//  Copyright (c) 2012 BeamApp UG. All rights reserved.
//

#import "BeamMinimalExampleProvider.h"
#import "DPMusicController.h"

@implementation BeamMinimalExampleProvider

#pragma mark Minimal Datasource Methods

-(NSString*)musicPlayer:(BeamMusicPlayerViewController *)player titleForTrack:(NSUInteger)trackNumber {

    NSString* retVal = nil;
    DPMusicController* controller = [DPMusicController sharedController];
    if([[controller queue] count] != 0) {
        
        retVal = [controller currentSong].title;
    }
    return retVal;
}

-(NSString*)musicPlayer:(BeamMusicPlayerViewController *)player artistForTrack:(NSUInteger)trackNumber {
    
    NSString* retVal = nil;
    DPMusicController* controller = [DPMusicController sharedController];
    if([[controller queue] count] != 0) {
        
        retVal = [controller currentSong].artistName;
    }
    return retVal;
}


-(NSString*)musicPlayer:(BeamMusicPlayerViewController *)player albumForTrack:(NSUInteger)trackNumber {

    NSString* retVal = nil;
    DPMusicController* controller = [DPMusicController sharedController];
    if([[controller queue] count] != 0) {
        
        retVal = [controller currentSong].albumTitle;
    }
    return retVal;
}

-(CGFloat)musicPlayer:(BeamMusicPlayerViewController *)player lengthForTrack:(NSUInteger)trackNumber {
   
    CGFloat retVal = 0;
    DPMusicController* controller = [DPMusicController sharedController];
    if([[controller queue] count] != 0) {
        
        retVal = [[DPMusicController sharedController] duration];
    }
    return retVal;
}

#pragma mark optional
-(CGFloat)volumeForMusicPlayer:(BeamMusicPlayerViewController*)player {
    return [DPMusicController sharedController].player.volume;
}

-(NSInteger)numberOfTracksInPlayer:(BeamMusicPlayerViewController *)player {

    return [DPMusicController sharedController].queue.count;
}


-(void)musicPlayer:(BeamMusicPlayerViewController *)player artworkForTrack:(NSUInteger)trackNumber receivingBlock:(BeamMusicPlayerReceivingBlock)receivingBlock {
    
    DPMusicController* controller = [DPMusicController sharedController];

    if([[controller queue] count] != 0) {
        UIImage* image = [[controller currentSong] getRepresentativeImageForSize:player.preferredSizeForCoverArt];
        
        if ( image ){
            receivingBlock(image, nil);
        } else {
            receivingBlock(nil,nil);
        }
    }
}
/* ALT
-(void)musicPlayer:(BeamMusicPlayerViewController *)player artworkForTrack:(NSUInteger)trackNumber receivingBlock:(BeamMusicPlayerReceivingBlock)receivingBlock {
    NSString* url = @"http://a3.mzstatic.com/us/r1000/045/Features/7f/50/ee/dj.zygromnm.600x600-75.jpg";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSData* urlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        
        UIImage* image = [UIImage imageWithData:urlData];
        receivingBlock(image,nil);
    });
} */

// NEW BEAM ISH
// -(CGFloat)musicPlayer:(BeamMusicPlayerViewController*)player currentPositionForTrack:(NSUInteger)trackNumber {
//    return player.currentPlaybackPosition + 1.0f;
// }


#pragma mark Delegate Methods ( Used to control the music player )

-(NSInteger)musicPlayer:(BeamMusicPlayerViewController *)player didChangeTrack:(NSUInteger)track {
    /*
    if(self.mediaItems) {
        [self.musicPlayer setNowPlayingItem:[self mediaItemAtIndex:track]];
    } else {
        int delta = track - self.musicPlayer.indexOfNowPlayingItem;
        if(delta > 0)
            [self.musicPlayer skipToNextItem];
        if(delta == 0)
            [self.musicPlayer skipToBeginning];
        if(delta < 0)
            [self.musicPlayer skipToPreviousItem];
    }
    return self.musicPlayer.indexOfNowPlayingItem; */
}

-(void)musicPlayerDidStartPlaying:(BeamMusicPlayerViewController *)player {
    if (![[DPMusicController sharedController] isPlaying]) {
        [[DPMusicController sharedController] play:nil];
    }
}

-(void)musicPlayerDidStopPlaying:(BeamMusicPlayerViewController *)player {
    if ([[DPMusicController sharedController] isPlaying]) {
        [[DPMusicController sharedController] pause:nil];
    }
}

-(void)musicPlayer:(BeamMusicPlayerViewController *)player didChangeVolume:(CGFloat)volume {
    [[DPMusicController sharedController] setVolume:volume];
}

-(void)musicPlayer:(BeamMusicPlayerViewController *)player didSeekToPosition:(CGFloat)position {
    
    //[self.musicPlayer setCurrentPlaybackTime:position];
    //[[DPMusicController sharedController] setTrackPosition:position ];

    [[DPMusicController sharedController] seekToTime:position ];

    
  // self.remainingLabel.text = [[[DPMusicController sharedController].player ] remainingTimeString];
  // self.elapsedLabel.text = [[DPMusicController sharedController] elapsedTimeString];
  // self.scrubSlider.value = [[DPMusicController sharedController] trackPosition] / [[DPMusicController sharedController] duration];
}


-(BOOL)musicPlayerShouldStartPlaying:(BeamMusicPlayerViewController*)player {
    // If return value is NO, the player won't start playing.
    // YES, tells the player to starts. Default is YES.
    return YES;
}

-(void)musicPlayerDidStopPlayingLastTrack:(BeamMusicPlayerViewController*)player {
    //  Called after the player stopped playing the last track.
}

-(BOOL)musicPlayerShouldStopPlaying:(BeamMusicPlayerViewController*)player {
    // By returning NO here, the delegate may prevent the player from stopping the playback
    return YES;
}

-(BOOL)musicPlayer:(BeamMusicPlayerViewController*)player shouldChangeTrack:(NSUInteger)track {
    // return YES if the track can be changed, NO if not. Default YES.
    return YES;
}

-(void)musicPlayer:(BeamMusicPlayerViewController*)player didChangeShuffleState:(BOOL)shuffling {
    // YES indicates the player is shuffling now, i.e. randomly selecting a next track from the valid range of tracks
    // NO means there is no shuffling.
}

-(void)musicPlayer:(BeamMusicPlayerViewController*)player didChangeRepeatMode:(MPMusicRepeatMode)repeatMode {
    // The repeat modes are taken from MediaPlayer framework and indicate
    // whether the player is in No Repeat, Repeat Once or Repeat All mode.
}

@end
