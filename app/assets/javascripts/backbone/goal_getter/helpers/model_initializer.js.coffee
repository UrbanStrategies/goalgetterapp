GoalGetter.Helpers.ModelInitializer =
  initialize_model: (model_obj) ->
    model_obj.overlay_texts =
      '3':
        title: 'Share Portfolio'
        body: 'Share your portfolio: http://www.goalgetterapp.com/portfolio'
        
    model_obj.logged_out_texts =
      'milestones':
        title: 'Create and view milestones shared between students and counselors'
        body: 'GoalGetter allows counselors to create milestones that their students can follow to keep up-to-date on what they need to do to finish the semester successfully.'
        bkgrd_color: '#00b9e6'        
    
      'jobboard':
        title: 'See job listings posted by your counselors'
        body: 'GoalGetter customizes job listings by your school\'s location and allows your counselors and teachers to feature listings they have found in the community.'
        bkgrd_color: '#00b9e6'        
      '2':
        title: 'Get in touch with your school\'s counselor'
        body: 'Find out how many credits you need to graduate, what classes you need to sign up for - no need for an appointment!'
        img_url: '/images/logged_out_counselor.png'
        bkgrd_color: '#00b9e6'
      '3':
        title: 'Build your portfolio and share with potential employers'
        body: 'Use the guides to build your portfolio, and send your portfolio to employers as a resume.'
        img_url: '/images/logged_out_portfolio.png'
        bkgrd_color: '#00b9e6'
      '4':
        title: 'Add and store your professional contacts'
        body: 'Build a list of employer references and other community members in one place to stay organized when applying for housing or a new job.'
        img_url: '/images/logged_out_contacts.png'
        bkgrd_color: '#00b9e6'
        

    # without this entry, you can't navigate directly to this.
    model_obj.directory_level =
      '0': 0
      '1': 0
      '2': 0
      '3': 0
      '4': 0
      'jobboard': 0
      'milestones': 0
      'chat': 1
      'add-work-experience' : 1
      'add-an-achievement' : 1
      'add-service': 1
      'search-results': 1
      'guide-single': 1
      'logged-out': 0
      'public-portfolio': 1
      'add-milestone': 1
      
    model_obj.up_level =
      'chat': '2'
      'add-work-experience' : '3'
      'add-an-achievement' : '3'
      'search-results': '0'
      'guide-single': '1'
      'public-portfolio': '3'
      'add-service': '0'
      'add-milestone': 'milestones'
      
    model_obj.header_config =
      'jobboard':
        properties:
          search: true
      'milestones':
        properties:
          add: true
      '0' :
        properties:
          search: true
          add: true
      '1' :
        properties:
          search: true
      '3' :
        properties:
          share: true
      'guide-single':
        properties:
          save: true
          share: true
      'add-service':
        properties:
          done: true
          done_refreshes: true
      'add-milestone':
        properties:
          done: true
          done_refreshes: true
      'add-work-experience' :
        properties:
          done: true
          done_refreshes: true
      'add-an-achievement' :
        properties:
          done: true
          done_refreshes: true
      'search-results':
        properties:
          search: true
      'public-portfolio':
        properties: {}

    model_obj.requires_login =
      '0': ['none']
      '1': ['none']
      '2': ['user']
      '3': ['user']
      '4': ['user']
      'jobboard': ['none']
      'milestones': ['user', 'admin']
      'add-milestone': ['admin']
      'add-work-experience': ['user']
      'add-an-achievement' : ['user']
      'add-service': ['user']
      'chat': ['user']
      'search-results': ['none']
      'guide-single' : ['none']
      'logged-out': ['none']
      'overlay' : ['user']
      'portfolio-friends': ['user']
      'portfolio-likes': ['user']
      'guides-saved': ['user']
      'public-portfolio': ['user']
      
    model_obj.screen_data_ready =
      '0': true
      '1': false
      '2': false
      '3': false
      '4': false
      'chat': false
      'add-service': true
      'add-work-experience': true
      'add-an-achievement' : true
      'search-results': false
      'guide-single' : false
      'logged-out': true
      'overlay': false
      'guides-saved': false
      'portfolio-friends': false
      'portfolio-likes': false
      'public-portfolio': false
      'add-milestone': true
      
    model_obj.texts =
      '0': 'Services',
      '1': 'Guides',
      '2': 'Counselor'
      '3': 'Portfolio',
      '4': 'Contact',
      'jobboard': 'Job Board',
      'milestones': 'Milestones',
      'chat' : '$current_chat_counselor'
      'add-service': 'Add Service'
      'add-milestone': 'Add Milestone'
      'add-work-experience' : 'Add job experience'
      'add-an-achievement' : 'Add achievement'
      'guide-single' : '$body_guide_title'
      'search-results': '$viewable_search_query'
      'guides-saved': 'Guides'
      'portfolio-friends': 'Portfolio'
      'portfolio-likes': 'Portfolio'
      'logged-out': 'Sign In'
      'public-portfolio': '$public_portfolio_name'

  resolve_to_class_name: (index) ->
    switch index
      when '0' then 'ServicesView'
      when '1' then 'GuidesView'
      when '2' then 'CounselorView'
      when '3' then 'PortfolioView'
      when '4' then 'ContactsView'
      when 'jobboard' then 'JobBoardView'
      when 'milestones' then 'MilestonesView'
      when 'chat' then 'ChatView'
      when 'add-work-experience' then 'AddWorkView'
      when 'add-service' then 'AddService'
      when 'add-milestone' then 'AddMilestone'
      when 'add-an-achievement' then 'AddAnAchievement'
      when 'search-results' then 'SearchResultsView'
      when 'guide-single' then 'GuideSingleView'
      when 'logged-out' then 'LoggedOutView'
      when 'portfolio-friends' then 'PortfolioTabFriendsView'
      when 'portfolio-likes' then 'PortfolioTabLikesView'
      when 'guides-saved' then 'GuidesTabView'
      when 'public-portfolio' then 'PortfolioView'
