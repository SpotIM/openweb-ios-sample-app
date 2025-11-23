//
//  VideoExampleViewModel.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Shprung on 28/09/2025.
//

import Combine

protocol VideoExampleViewModelingInputs {
    func play()
}

protocol VideoExampleViewModelingOutputs {
    var startPlayingVideo: AnyPublisher<Void, Never> { get }
}

protocol VideoExampleViewModeling {
    var inputs: VideoExampleViewModelingInputs { get }
    var outputs: VideoExampleViewModelingOutputs { get }
}

class VideoExampleViewModel: VideoExampleViewModeling, VideoExampleViewModelingInputs, VideoExampleViewModelingOutputs {
    var inputs: VideoExampleViewModelingInputs { return self }
    var outputs: VideoExampleViewModelingOutputs { return self }

    private let _startPlayingVideo = PassthroughSubject<Void, Never>()
    var startPlayingVideo: AnyPublisher<Void, Never> {
        _startPlayingVideo
            .eraseToAnyPublisher()
    }

    func play() {
        _startPlayingVideo.send(())
    }
}
